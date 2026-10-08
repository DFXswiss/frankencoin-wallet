import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewPage extends BasePage {
  WebViewPage(this._title, this._url, {super.key});

  final String _title;
  final Uri _url;

  @override
  String get title => _title;

  @override
  Widget body(BuildContext context) => WebViewPageBody(_url);
}

class WebViewPageBody extends StatefulWidget {
  const WebViewPageBody(this.uri, {super.key});

  final Uri uri;

  @override
  WebViewPageBodyState createState() => WebViewPageBodyState();
}

class WebViewPageBodyState extends State<WebViewPageBody> {
  static const _mediaPermissionHosts = ["dfx.swiss", "sumsub.com"];

  Future<bool> _pendingOsPermissionRequest = Future.value(true);

  @override
  Widget build(BuildContext context) => InAppWebView(
        initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            allowsInlineMediaPlayback: true,
            mediaPlaybackRequiresUserGesture: false,
            resourceCustomSchemes: ["frankencoin-wallet"]),
        initialUrlRequest: URLRequest(url: WebUri.uri(widget.uri)),
        onLoadStart: (InAppWebViewController controller, WebUri? url) {
          if (url?.scheme == "frankencoin-wallet") {
            controller.stopLoading();
            Navigator.of(context).pop(url.toString());
          }
        },
        onPermissionRequest: (_, request) async => PermissionResponse(
            resources: request.resources,
            action: await _isMediaPermissionGranted(request)
                ? PermissionResponseAction.GRANT
                : PermissionResponseAction.DENY),
      );

  Future<bool> _isMediaPermissionGranted(PermissionRequest request) async {
    final host = request.origin.host;
    final isTrustedOrigin = request.origin.scheme == "https" &&
        _mediaPermissionHosts
            .any((allowed) => host == allowed || host.endsWith(".$allowed"));
    if (!isTrustedOrigin || request.resources.isEmpty) return false;

    final permissions = <Permission>{};
    for (final resource in request.resources) {
      if (resource == PermissionResourceType.CAMERA) {
        permissions.add(Permission.camera);
      } else if (resource == PermissionResourceType.MICROPHONE) {
        permissions.add(Permission.microphone);
      } else if (resource == PermissionResourceType.CAMERA_AND_MICROPHONE) {
        permissions.addAll([Permission.camera, Permission.microphone]);
      } else {
        return false;
      }
    }

    return _requestOsPermissions(permissions.toList());
  }

  // Only one OS permission request may run at a time, so queue them.
  Future<bool> _requestOsPermissions(List<Permission> permissions) {
    final result = _pendingOsPermissionRequest.then((_) async {
      try {
        final statuses = await Future.wait(permissions.map((p) => p.status));
        if (statuses.every((status) => status.isGranted)) return true;

        final requested = await permissions.request();
        return requested.values.every((status) => status.isGranted);
      } on PlatformException {
        return false;
      }
    });
    _pendingOsPermissionRequest = result.catchError((_) => false);
    return result;
  }
}
