import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';

abstract class BasePage extends StatelessWidget {
  BasePage({super.key}) : _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey;

  String? get title => null;

  bool get resizeToAvoidBottomInset => true;

  bool get extendBodyBehindAppBar => false;

  Widget? get endDrawer => null;

  Widget Function(BuildContext, Widget)? get rootWrapper => null;

  // ThemeBase get currentTheme => getIt.get<SettingsStore>().currentTheme;

  void onOpenEndDrawer() => _scaffoldKey.currentState!.openEndDrawer();

  void onClose(BuildContext context) => Navigator.of(context).pop();

  Color pageBackgroundColor(BuildContext context) =>
      const Color.fromRGBO(17, 24, 39, 1.0);

  // (currentTheme.type == ThemeType.dark
  //     ? backgroundDarkColor
  //     : backgroundLightColor) ??
  //     (gradientBackground && currentTheme.type == ThemeType.bright
  //         ? Colors.transparent
  //         : Theme.of(context).colorScheme.background);

  Color titleColor(BuildContext context) => Colors.white;

  // (gradientBackground && currentTheme.type == ThemeType.bright) ||
  //     (gradientAll && currentTheme.brightness == Brightness.light)
  //     ? Colors.white
  //     : Theme.of(context).appBarTheme.titleTextStyle!.color!;

  Color? pageIconColor(BuildContext context) => titleColor(context);

  Widget closeButton(BuildContext context) => Icon(
        Icons.close,
        color: pageIconColor(context),
        size: 16,
      );

  Widget backButton(BuildContext context) => Icon(
        Icons.arrow_back_ios,
        color: pageIconColor(context),
        size: 16,
      );

  Widget? leading(BuildContext context) {
    if (ModalRoute.of(context)?.isFirst ?? true) return null;

    return MergeSemantics(
      child: SizedBox(
        height: 37,
        width: 37,
        child: ButtonTheme(
          minWidth: double.minPositive,
          child: Semantics(
            label: S.of(context).back,
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => Colors.transparent),
              ),
              onPressed: () => onClose(context),
              child: backButton(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget? middle(BuildContext context) {
    return title == null
        ? null
        : Text(
            title!,
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
                color: titleColor(context)),
          );
  }

  Widget? trailing(BuildContext context) => null;

  Widget? floatingActionButton(BuildContext context) => null;

  ObstructingPreferredSizeWidget appBar(BuildContext context) =>
      CupertinoNavigationBar(
        leading: leading(context),
        middle: middle(context),
        trailing: trailing(context),
        backgroundColor: pageBackgroundColor(context),
        border: null,
      );

  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final root = Scaffold(
        key: _scaffoldKey,
        backgroundColor: pageBackgroundColor(context),
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        endDrawer: endDrawer,
        appBar: appBar(context),
        body: SafeArea(child: body(context)),
        floatingActionButton: floatingActionButton(context));

    return rootWrapper?.call(context, root) ?? root;
  }
}
