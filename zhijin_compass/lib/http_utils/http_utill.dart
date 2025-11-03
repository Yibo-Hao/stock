import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zhijin_compass/screens/roots/root_event_bus.dart';
import 'package:zhijin_compass/screens/roots/root_page.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/tools/ZzCustomDialog.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

class BaseUrl {
  static var url = kDebugMode
      ? 'http://qa-test.qcoral.tech'
      : "https://ai.qcoral.tech";
  static var webUrl = "http://web-prod.qcoral.tech";
}

class HttpUtil {
  static HttpUtil? instance;
  Dio? dio;
  BaseOptions? options;
  List<Map<String, dynamic>> requestRecords = [];

  CancelToken cancelToken = CancelToken();

  static HttpUtil getInstance() {
    instance ??= HttpUtil();
    return instance!;
  }

  //登录退出登录时调用
  static cleariInstance() {
    instance = null;
  }

  /*
   * config it and create
   */
  HttpUtil() {
    // String? proxy = BaseSpStorage.getInstance().proxy;
    //BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    options = BaseOptions(
      baseUrl: BaseUrl.url,
      connectTimeout: const Duration(milliseconds: 20000),
      receiveTimeout: const Duration(milliseconds: 20000),
      //Http请求头.
      headers: {
        // "platform": "ios",
        // "appVersion": "1.0.1",
      },
      //表示期望以那种格式(方式)接受响应数据。接受4种类型 `json`, `stream`, `plain`, `bytes`. 默认值是 `json`,
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
    );
    dio = Dio(options);

    // if ($notempty(proxy)) {
    //   (dio?.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    //     return HttpClient()
    //       ..findProxy = (uri) {
    //         return 'PROXY $proxy';
    //       };
    //   };
    // }
    // (dio?.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    //   return HttpClient()
    //     ..findProxy = (uri) {
    //       return 'PROXY 192.168.2.160:8888';
    //     };
    // };
    dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          String token = BaseSpStorage.getInstance().userToken;
          options.headers["X-userToken"] = token;
          options.headers["X-deviceId"] = BaseSpStorage.getInstance().deviceId;
          options.headers["X-systemType"] = "android";
          options.headers["X-appVersion"] = "1.0.0";
          options.baseUrl = BaseUrl.url;
          return handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  /*
   * get请求
   * checkFormat参数用于判断是否需要验证返回格式，默认需要
   */
  get(
    String url, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function? successCallback,
    Function? errorCallback,
    Options? options,
    bool checkFormat = true,
  }) async {
    Response response;
    try {
      response = await dio!.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      handleResponse(response, successCallback!, errorCallback!, checkFormat);
    } on DioException catch (e) {
      formatError(
        errorCallback!,
        e,
        url: url,
        option: options,
        type: "get",
        response: {},
        body: {},
        pama: queryParameters,
      );
    }
  }

  /*
   * post请求
   */
  post(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function? successCallback,
    Function(int, int)? onSendProgress,
    Function? errorCallback,
    Options? options,
    bool checkFormat = true,
  }) async {
    Response response;
    try {
      response = await dio!.post(
        url,
        data: data,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
        options: options,
        cancelToken: cancelToken,
      );

      handleResponse(response, successCallback!, errorCallback!, checkFormat);
    } on DioException catch (e) {
      formatError(
        errorCallback!,
        e,
        url: url,
        option: options,
        type: "post",
        response: e.response,
        body: (data is Map) ? data : {},
        pama: queryParameters,
      );
    }
  }

  handleResponse(
    Response response,
    Function successCallback,
    Function errorCallback,
    bool checkFormat,
  ) {
    try {
      String code;
      String msg;
      // ignore: prefer_typing_uninitialized_variables
      var backData;
      if (response.statusCode != 200) {
        _handError(
          errorCallback,
          response.statusCode.toString(),
          response.statusMessage ?? "未知的错误回调",
        );
        return;
      }

      if (checkFormat) {
        Map<String, dynamic> resCallbackMap = response.data;
        code = resCallbackMap['code'];
        msg = resCallbackMap['message'];
        backData = resCallbackMap['data'];

        if (code.toString() == "00000") {
          successCallback(backData);
          return;
        } else if (code.toString() == "10003") {
          if ($notempty(BaseSpStorage.getInstance().userToken)) {
            BaseSpStorage.getInstance().setUserModel(null);
            BaseSpStorage.getInstance().setUserToken("");

            // 延迟1s
            Future.delayed(Duration(milliseconds: 400), () {
              ZzCustomDialog.show(
                context: navigatorKey.currentContext!,
                image: Positioned(
                  top: -75,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/dialog_warnning.png',
                    height: 150,
                  ),
                ),
                barrierDismissible: false,
                content:
                    '您的账号刚刚在另一部设备上登录，为了您的账号安全，我们已将您从当前设备登出。如果不是您本人操作，请尽快修改密码，保护您的账号安全。',
                singleButton: true,
                rightButtonText: "确认",
                rightButtonAction: () {
                  zzEventBus.fire(LoginBus(false));
                  HttpUtil.cleariInstance();
                  safeGoback(navigatorKey.currentContext!);
                },
              );
            });
          }
          return;
        } else if (code.toString() == "20115") {
          //代表验证码还在生效中,正常跳转页面
          successCallback(backData);
        } else if (code.toString() == "10002") {
          //token失效重新登录
          if ($notempty(BaseSpStorage.getInstance().userToken)) {
            ZzLoading.showMessage("登录失效,请重新登录");
            BaseSpStorage.getInstance().setUserModel(null);
            BaseSpStorage.getInstance().setUserToken("");
            zzEventBus.fire(LoginBus(false));
          }
          return;
        }

        _handError(errorCallback, code.toString(), msg);
        return;
      }
      successCallback(response.data);
    } catch (exception) {
      if (kDebugMode) {
        _handError(errorCallback, '-10000', exception.toString());
      } else {
        _handError(errorCallback, '-10000', "找不到任何结果");
      }
    }
  }

  // 返回错误信息
  static void _handError(
    Function errorCallback,
    String errorCode,
    String errorMsg,
  ) {
    errorCallback(
      errorCode,
      errorMsg.toString().isNotEmpty ? errorMsg : "网络异常，请稍后重试",
    );
  }

  /*
   * DioError 统一处理
   */
  void formatError(
    Function errorCallback,
    DioException e, {
    String? url,
    String? type,
    Map? pama,
    Map? body,
    dynamic option,
    dynamic response,
  }) {
    String? code = (e.response != null)
        ? e.response?.statusCode.toString()
        : "9999";
    String? msg = (e.response != null)
        ? e.response?.statusMessage
        : '网络异常，请稍后重试';
    _handError(errorCallback, code.toString(), msg!);
  }

  /*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }
}
