import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';

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
  @override
  Widget build(BuildContext context) => InAppWebView(
        initialSettings: InAppWebViewSettings(
          transparentBackground: true,
        ),
        initialUrlRequest: URLRequest(url: WebUri.uri(widget.uri)),
        onLoadStart: (InAppWebViewController controller, WebUri? url) {
          if (url.toString().startsWith("frankencoin-wallet://")) {
            Navigator.of(context).pop();
            controller.stopLoading();
          }
        },
        // onNavigationResponse: (InAppWebViewController controller,
        //     NavigationResponse navigationResponse) async {
        //   if (navigationResponse.response?.url?.host.endsWith("dfx.swiss") == true) {
        //     return NavigationResponseAction.ALLOW;
        //   }
        //   return NavigationResponseAction.CANCEL;
        // },
      );
}
