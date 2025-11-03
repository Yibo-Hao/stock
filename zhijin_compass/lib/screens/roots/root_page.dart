library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:zhijin_compass/screens/roots/root_page_life.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.builder}) : super(key: key);
  final TransitionBuilder builder;

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('assets/images/mine_bg.png'), context);
    BaseSpStorage.getInstance().setAutoLogin(false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, //只能纵向
      DeviceOrientation.portraitDown, //只能纵向
    ]);
    return OKToast(
      child: GetMaterialApp(
        key: key,
        showPerformanceOverlay: false,

        title: '智金罗盘', //此处就是后台显示的名称
        navigatorKey: navigatorKey,
        navigatorObservers: [defaultLifecycleObserver],
        theme: ThemeData(
          /// 修改默认转场（安卓和 iOS 统一转场动画）
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          brightness: Brightness.light,
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: ZzColor.mainAppColor,
            selectionHandleColor: ZzColor.mainAppColor,
          ),
          colorScheme: const ColorScheme(
            brightness: Brightness.light, //亮度
            primary: ZzColor.whiteColor, //主要颜色，通常用于应用程序的主要元素，如导航栏、按钮等。
            onPrimary: ZzColor.color_111111, //在主要颜色上的文本和图标的颜色。
            secondary: ZzColor.color_333333, //在次要颜色上的文本和图标的颜色。
            onSecondary: ZzColor.color_666666, //次要变体颜色，通常用于强调或突出显示次要颜色的元素。
            error: ZzColor.colorToE82B2B, //错误颜色，用于表示错误状态的元素，如验证错误、网络错误等。
            onError: ZzColor.colorToE82B2B, //在错误颜色上的文本和图标的颜色。
            background: ZzColor.pageBackGround, //背景颜色，通常用于应用程序的背景元素。
            onBackground: ZzColor.whiteColor, //在背景颜色上的文本和图标的颜色。
            surface: ZzColor.whiteColor, //表面颜色，通常用于应用程序的表面元素，如卡片、对话框等。
            onSurface: ZzColor.color_111111, //在表面颜色上的文本和图标的颜色。
          ),

          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          fontFamily: Platform.isIOS ? "PingFang SC" : "Roboto",
          textTheme: TextTheme(
            displayLarge: ZzFonts.fontMedium333(16), //用于大型展示文本的样式。
            displayMedium: ZzFonts.fontMedium333(14), //用于中型展示文本的样式。
            displaySmall: ZzFonts.fontMedium333(12), //用于小型展示文本的样式。
            headlineLarge: ZzFonts.fontBold111(20), //用于大型标题文本的样式。
            headlineMedium: ZzFonts.fontBold111(15), //用于中型标题文本的样式。
            headlineSmall: ZzFonts.fontBold111(12), //用于小型标题文本的样式。
            titleLarge: ZzFonts.fontBold111(20), //用于大型标题文本的样式。
            titleMedium: ZzFonts.fontBold111(15), //用于中型标题文本的样式。
            titleSmall: ZzFonts.fontBold111(12), //用于小型标题文本的样式。
            bodyLarge: ZzFonts.fontMedium333(16), //用于大型正文文本的样式。
            bodyMedium: ZzFonts.fontMedium333(14), //用于中型正文文本的样式。
            bodySmall: ZzFonts.fontMedium333(12), //用于小型正文文本的样式。
            labelLarge: ZzFonts.fontBold333(16), //用于大型标签文本的样式。
            labelMedium: ZzFonts.fontBold333(14), //用于中型标签文本的样式。
            labelSmall: ZzFonts.fontBold333(12), //用于小型标签文本的样式。
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        //builder:
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(Platform.isIOS ? 1.1 : 1.0)),
          child: Builder(
            builder: (BuildContext context) {
              return builder(context, child);
            },
          ),
        ),

        //home: const WelcomePage(),
        initialRoute: BaseSpStorage.getInstance().isAgreeProl == 'true'
            ? "index_page"
            : "welcome_page",

        onGenerateRoute: onGenerateRoute,
        localizationsDelegates: const [
          RefreshLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          // 添加中文本地化代理
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // 英语（美国）
          Locale('zh', 'CN'), // 中文（中国）
          // 添加其他支持的语言
        ],
      ),
    );
  }
}

// class RestartWidget extends StatefulWidget {
//   final Widget child;

//   const RestartWidget({Key? key, required this.child}) : super(key: key);

//   static restartApp(BuildContext context) {
//     //final State<StatefulWidget>? state = context.findAncestorStateOfType();
//     final _RestartWidgetState? state =
//         context.findAncestorStateOfType<_RestartWidgetState>();
//     state?.restartApp();
//   }

//   @override
//   _RestartWidgetState createState() => _RestartWidgetState();
// }

// class _RestartWidgetState extends State<RestartWidget> {
//   Key key = UniqueKey();
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     ConfigModel.value.navigatorKey = navigatorKey;

//     //InitSpUntill();
//   }

//   // ignore: non_constant_identifier_names
//   // InitSpUntill() async {
//   //   SpUtil.getInstance().init();
//   // }
//   // = GlobalKey<NavigatorState>();
//   void restartApp() {
//     setState(() {
//       // printf("restartApp", current: StackTrace.current);
//       navigatorKey = GlobalKey<NavigatorState>();
//       ConfigModel.value.navigatorKey = navigatorKey;
//       key = UniqueKey();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     ScreenModel().setContent(context);
//     return Container(
//       key: key,
//       child: widget.child,
//     );
//   }
// }
