import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http_proxy/http_proxy.dart';
import 'package:zhijin_compass/http_utils/http_override.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'screens/roots/root_page.dart';
// import 'package:jpush_flutter/jpush_flutter.dart';
// import 'package:jpush_flutter/jpush_interface.dart';

Future<void> main() async {
  // final JPushFlutterInterface jpush = JPush.newJPush();
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    HttpProxy httpProxy = await HttpProxy.createHttpProxy();
    HttpOverrides.global = httpProxy;
  } else {
    HttpOverrides.global = MyHttpOverrides();
  }
  // jpush.setAuth(enable: true);
  ZTool.inittools();
  runApp(MyApp(builder: EasyLoading.init()));
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
