import 'package:flutter/material.dart';
import 'package:zhijin_compass/screens/deal/page/deal_page.dart';
import 'package:zhijin_compass/screens/home/page/home_page.dart';
import 'package:zhijin_compass/screens/home/page/stock_detail_page.dart';
import 'package:zhijin_compass/screens/login/page/login_code_page.dart';
import 'package:zhijin_compass/screens/login/page/login_page.dart';
import 'package:zhijin_compass/screens/message/page/message_list_page.dart';
import 'package:zhijin_compass/screens/message/page/message_page.dart';
import 'package:zhijin_compass/screens/mine/page/about_page.dart';
import 'package:zhijin_compass/screens/mine/page/customer_service_page.dart';
import 'package:zhijin_compass/screens/mine/page/mine_page.dart';
import 'package:zhijin_compass/screens/mine/page/permission_page.dart';
import 'package:zhijin_compass/screens/mine/page/push_setting_page.dart';
import 'package:zhijin_compass/screens/roots/base_webview_page.dart';
import 'package:zhijin_compass/screens/news/page/news_page.dart';
import 'package:zhijin_compass/screens/roots/root_index.dart';
import 'package:zhijin_compass/screens/search/page/stock_search_page.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

Map<String, WidgetBuilder> allRoutes = {};
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  print("注册路由成功");
  var name = settings.name;
  // 记录注册的路由
  if (settings.name == "index_page") {
    return PageRouteBuilder(
      // transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => IndexPage(),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
    );
  }
  // if (settings.name == "welcome_page") {
  //   return PageRouteBuilder(
  //     pageBuilder: (_, __, ___) => const WelcomePage(),
  //     transitionsBuilder: (_, animation, __, child) {
  //       return FadeTransition(
  //         opacity: animation,
  //         child: ScaleTransition(
  //           scale: Tween<double>(begin: 1.5, end: 1.0).animate(animation),
  //           child: child,
  //         ),
  //       );
  //     },
  //   );
  // }
  var routes = <String, WidgetBuilder>{
    "index_page": (_) => IndexPage(),
    "home_page": (_) => const HomePage(), //首页
    "deal_page": (_) => const DealPage(), //首页
    "mine_page": (_) => const MinePage(), //我的
    "login_page": (_) => const LoginPage(),
    "news_page": (_) => const NewsPage(), //首页
    "base_webview_page": (_) => BaseWebViewPage(
      url: _getParam(settings.arguments, "url"),
      title: _getParam(settings.arguments, "title"),
    ), //我的
    "stock_detail_page": (_) =>
        StockDetailPage(model: _getParam(settings.arguments, "model")), //我的
    "login_code_page": (_) => LoginCodePage(
      phoneNum: _getParam(settings.arguments, "phoneNum"),
      saveCallBack: _getParam(settings.arguments, "saveCallBack"),
    ), //校验验证码页面
    "stock_search_page": (_) => const StockSearchPage(), //搜索页面
    "push_settings_page": (_) => const PushSettingPage(), //推送设置页面
    "permission_page": (_) => const PermissionPage(),
    "customer_service_page": (_) => const CustomerServicePage(),
    "about_page": (_) => const AboutPage(),
    "message_page": (_) => const MessagePage(),
    "message_detail_page": (_) =>
        MessageListPage(params: _getParam(settings.arguments, "params")),
  };
  allRoutes = routes;
  WidgetBuilder? builder = routes[settings.name];

  if (builder == null) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: ZzAppBar(title: '开发中'),
        body: Center(child: Text('敬请期待: ${settings.name}')),
      ),
    );
  }

  return MaterialPageRoute(settings: settings, builder: (ctx) => builder(ctx));
}

dynamic _getParam(dynamic args, String key) {
  if (args == null) return null;
  return args[key];
}

safePushToPage(BuildContext context, String pageString, {Object? arguments}) {
  // if (1 > 0) {
  //   if (allRoutes.containsKey(pageString)) {
  //     Navigator.of(context).pushNamed(pageString, arguments: arguments);
  //   } else {
  //     ZzLoading.showMessage("未知的页面");
  //   }
  // }
  Navigator.of(context).pushNamed(pageString, arguments: arguments);
}

void constPushToPage(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  // Navigator.push(
  //   context,
  //   PageRouteBuilder(
  //     transitionDuration: Duration(milliseconds: 200),
  //     //动画时间为500毫秒
  //     pageBuilder: (context, animation, secondaryAnimation) {
  //       return FadeTransition(
  //         //使用渐隐渐入过渡,
  //         opacity: animation,
  //         child: page,
  //       );
  //     },
  //   ),
  // );
}

void safeGoback(context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();

    return;
  }
  ZzLoading.showMessage("页面走丢了!");
  Navigator.of(context).pushNamedAndRemoveUntil("index_page", (route) => true);
}
