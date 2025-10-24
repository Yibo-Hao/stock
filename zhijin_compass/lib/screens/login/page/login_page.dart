import 'dart:io' show Platform;

import 'package:aliyun_push/aliyun_push.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_ali_auth/flutter_ali_auth.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
// import 'package:zhijin_compass/screens/login/page/login_example.dart';
import 'package:zhijin_compass/screens/roots/root_event_bus.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';

import 'package:shake_animation_widget/shake_animation_widget.dart';
import 'package:zhijin_compass/tools/ZzCustomDialog.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

/*

  WeatherBg(
                weatherType: WeatherType.thunder,
                width: ZzScreen().screenWidth,
                height: ZzScreen().screenHeight,
              ),
*/
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum PhoneInputStutas {
  waitinput, //等待输入
  inputing, //输入中
  inputend, //输入完成
  inputerr, //输入错误
}

enum LoginType {
  password, //密码
  safecode, //验证码
  auto, //一键登录
}

class _LoginPageState extends State<LoginPage> {
  PhoneInputStutas _phoneInputStutas = PhoneInputStutas.waitinput;
  // LoginType _loginType = LoginType.safecode;
  bool _isAgreeProtocol = false; //是否同意协议
  bool _isVisibility = true; //是否同意协议
  late TextEditingController _phoneEditingController;
  late TextEditingController _passWordEditingController;
  final FocusNode phoneNode = FocusNode();
  final _aliyunPush = AliyunPush();
  bool _supportOneClickLogin = false;
  String _androidSdk = "";
  // late final AuthConfig _authConfig = AuthConfig(
  //   iosSdk: '',
  //   androidSdk:
  //       'ympswY6hLZcVakWfFIMTd0bHI8L6+dlH4UgcytTc6IkKouavN00gEsxc9cnzfZfdzE9XFTezov49vfLStIE8/XnHplP64aDokIchKe23QCyw5W7xS7hVZbdQEagqK8lyjMnCvGq3CB3E4anvZpeSjTiNDX+fmEw8+/uVeLnVIf3U0YgnfyCCGmLzk3EwUBo2YkFs0H8BKeq9GHXFK9Ttna/acr6hHYDwPrX+atnZoO+Vimp3dblGY8Vo8NU7xlKTuqe0dlu8uuAz4n+EsIuBZ9sbYZWumDreMEO34/1ihHAF6IViIiFyCA==',
  //   enableLog: true,
  //   authUIStyle: AuthUIStyle.fullScreen,
  // );

  @override
  void initState() {
    super.initState();

    // AliAuthClient.handleEvent(onEvent: _onEvent);

    // AliAuthClient.handleEvent(
    //   onEvent: (response) async {
    //     final resultCode = AuthResultCode.fromCode(response.resultCode!);
    //     print("一键登录环境有回调");
    //     // 处理初始化、预取号、登录等回调
    //     switch (resultCode) {
    //       case AuthResultCode.success: // 600000
    //         // 成功处理
    //         print("一键登录环境ok");
    //         if (response.token != null && response.token!.isNotEmpty) {
    //           //验证成功，获取到token
    //           _postCodetoLoginUrl(response.token!);
    //           // await onToken(token: responseModel.token!);
    //         }

    //         break;
    //       case AuthResultCode.getMaskPhoneFailed:
    //         setState(() {
    //           _supportOneClickLogin = false;
    //         });
    //         break;
    //       case AuthResultCode.loginControllerClickProtocol:
    //         print("点击了协议");
    //         // safePushToPage(
    //         //   context,
    //         //   'base_webview_page',
    //         //   arguments: {
    //         //     "url": "${BaseUrl.webUrl}/contracts/agreement",
    //         //     "title": '服务协议',
    //         //   },
    //         // );
    //         break;

    //       case AuthResultCode.envCheckSuccess:
    //         print("支持认证");
    //         // setState(() {
    //         //   _loginType = LoginType.auto;
    //         // });
    //         BaseSpStorage.getInstance().setAutoLogin(true);
    //         // _loginAuto();
    //         // 环境检查成功
    //         setState(() {
    //           _supportOneClickLogin = true;
    //         });
    //         _loginAuto();
    //         break;
    //       // 其他状态码处理
    //       case AuthResultCode.loginControllerPresentFailed ||
    //           AuthResultCode.loginControllerClickCancel ||
    //           AuthResultCode.loginControllerClickChangeBtn: // 600000
    //         print("一键登录环境取消乌央乌央${response.resultCode}和${response.msg}");
    //         await AliAuthClient.quitLoginPage();
    //         break;

    //       default:
    //         print("一键登录失败code${response.resultCode}");
    //         print("一键登录失败msg${response.msg}");
    //         if (kDebugMode) {}
    //         ZzLoading.showMessage(response.msg ?? '不支持的环境');
    //         break;
    //     }
    //   },
    // );
    _phoneEditingController = TextEditingController();
    _phoneEditingController.text = "";
    _passWordEditingController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(phoneNode);
      print("一键登录进入123");

      // if (BaseSpStorage.getInstance().isAutoLogin == true) {
      //   print("一键登录进入456");
      // }
      // _initAutoLoginSdk();
    });
  }

  // _initAutoLoginSdk() async {
  //   _androidSdk = '';
  //   print("一键登录进入");
  //   //检测是不是release环境
  //   if (kReleaseMode) {
  //     _androidSdk =
  //         "m1lTEmQ+psI3+w3w+Oy/qbNlpeKqVZXTWREfuyuqStSPH/3ejAh3mrjBmy0cIKo4Yj0GGILvKx9nIL3T7nDVvNkbX9wt8xYsc7wZC3F3eEr3abO3idHUWpvrNy+/2UKc7XDPQjf2K04Sq47GfPqESNJyzfWz1OxjIFkqLzQGXNZCddnSb/jUPe4qhdaRG6Unk1v42bLr1Qq9RMKu7UTUls+gHosZT6GHotitikPlHSXYNp1GV1xwRfQI/08PQwuLolPm8Jau1I6YAFS3oEneoiLBtfpHqrf6eZGbZUWMxSpF07rtpOeZ9Q==";
  //   } else {
  //     _androidSdk =
  //         'ympswY6hLZcVakWfFIMTd0bHI8L6+dlH4UgcytTc6IkKouavN00gEsxc9cnzfZfdzE9XFTezov49vfLStIE8/XnHplP64aDokIchKe23QCyw5W7xS7hVZbdQEagqK8lyjMnCvGq3CB3E4anvZpeSjTiNDX+fmEw8+/uVeLnVIf3U0YgnfyCCGmLzk3EwUBo2YkFs0H8BKeq9GHXFK9Ttna/acr6hHYDwPrX+atnZoO+Vimp3dblGY8Vo8NU7xlKTuqe0dlu8uuAz4n+EsIuBZ9sbYZWumDreMEO34/1ihHAF6IViIiFyCA==';
  //   }

  //   await AliAuthClient.initSdk(
  //     authConfig: AuthConfig(
  //       iosSdk: "your_ios_sdk_key",
  //       androidSdk: _androidSdk,
  //       enableLog: true,
  //       // 其他配置参数
  //     ),
  //   );
  // }

  // _loginAuto() async {
  //   print("一键登录=====再次进入");

  //   try {
  //     _authConfig.authUIStyle = AuthUIStyle.fullScreen;
  //     _authConfig.authUIConfig = _extraUIBuilder(context);
  //     await AliAuthClient.loginWithConfig(authConfig: _authConfig, timeout: 10);
  //   } on PlatformException catch (e) {
  //     final AuthResultCode resultCode = AuthResultCode.fromCode(e.code);
  //     await AliAuthClient.quitLoginPage();
  //     debugPrint(resultCode.message);
  //   }
  // }

  // FullScreenUIConfig _extraUIBuilder(BuildContext context) {
  //   final screenSize = MediaQuery.of(context).size;
  //   const padding = 8.0;
  //   double loginSize = 100;
  //   double logoFrameOffsetY = (Platform.isAndroid ? 20 : 120) + kToolbarHeight;
  //   double sloganFrameOffsetY = logoFrameOffsetY + loginSize + padding;
  //   int sloganTextSize = 28;
  //   double numberFrameOffsetY = sloganFrameOffsetY + sloganTextSize + padding;
  //   int changeBtnTextSize = 14;
  //   double changeBtnFrameOffsetY =
  //       screenSize.height * (Platform.isAndroid ? 0.65 : 0.75);
  //   double iconSize = 48;
  //   double iconPadding = 12;
  //   double iconTotalSize = 48 * 3 + iconPadding * 2;
  //   double iconOffsetX1 = screenSize.width * 0.5 - iconTotalSize * 0.5;
  //   double iconOffsetY = changeBtnFrameOffsetY + changeBtnTextSize + 18;
  //   return FullScreenUIConfig(
  //     navConfig: const NavConfig(navIsHidden: true),
  //     backgroundImage: "assets/images/auto_bg.png",
  //     backgroundColor: Colors.white.toHex(),
  //     logoConfig: LogoConfig(
  //       logoIsHidden: false,
  //       logoImage: "assets/images/logo.png",
  //       logoWidth: loginSize,
  //       logoHeight: loginSize,
  //       logoFrameOffsetY: logoFrameOffsetY,
  //     ),

  //     privacyConfig: PrivacyConfig(
  //       privacyOneName: "《服务协议》",
  //       privacyTwoName: '《隐私政策》',
  //       privacyOneUrl: "${BaseUrl.webUrl}/contracts/agreement",
  //       privacyTwoUrl: "${BaseUrl.webUrl}/contracts/privacy-policy",
  //       privacyFontColor: ZzColor.mainAppColor.toHex(),
  //     ),
  //     checkBoxConfig: CheckBoxConfig(
  //       checkedImage: "assets/login/login_select_true.png",
  //       uncheckImage: "assets/login/login_select_false.png",
  //     ),
  //     // sloganConfig: SloganConfig(
  //     //   sloganIsHidden: false,
  //     //   sloganText: '欢迎登录智金罗盘',
  //     //   sloganTextColor: ,
  //     //   sloganTextSize: sloganTextSize,
  //     //   sloganFrameOffsetY: sloganFrameOffsetY,
  //     // ),
  //     phoneNumberConfig: PhoneNumberConfig(
  //       numberFontSize: 24,
  //       numberFrameOffsetY: numberFrameOffsetY,
  //       numberColor: Colors.pinkAccent.toHex(),
  //     ),
  //     loginButtonConfig: const LoginButtonConfig(
  //       // loginBtnTextColor: "#F9F9F9",
  //       loginBtnText: ' ',
  //       loginBtnWidth: 309,
  //       loginBtnHeight: 50,
  //       loginBtnNormalImage: "assets/images/login_btn_normal.png",
  //       loginBtnUnableImage: "assets/images/login_btn_normal.png",
  //       loginBtnPressedImage: "assets/images/login_btn_normal.png",
  //     ),
  //     changeButtonConfig: ChangeButtonConfig(
  //       changeBtnTextColor: "#A1A1A1",
  //       changeBtnFrameOffsetY: changeBtnFrameOffsetY,
  //       changeBtnTextSize: changeBtnTextSize,
  //     ),

  //     customViewBlockList: [],
  //   );
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    //AliAuthClient.removeHandler();
    super.dispose();
  }

  final ShakeAnimationController _shakeAnimationController =
      ShakeAnimationController();

  ///构建抖动效果
  ShakeAnimationWidget buildShakeAnimationWidget(Widget content) {
    return ShakeAnimationWidget(
      //抖动控制器
      shakeAnimationController: _shakeAnimationController,
      //微旋转的抖动
      shakeAnimationType: ShakeAnimationType.LeftRightShake,
      //设置不开启抖动
      isForward: false,
      //默认为 0 无限执行
      shakeCount: 1,
      //抖动的幅度 取值范围为[0,1]
      shakeRange: 0.5,
      //执行抖动动画的子Widget
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    ZzScreen().setContent(context);
    return inputWidget(
      context,
      Container(
        padding: EdgeInsets.all(20),
        height: ZzScreen().screenHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/auto_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            safeGoback(context);
                          }

                          return;
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: EdgeInsets.only(top: ZzScreen().paddingTop),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Image(
                              image: const AssetImage(
                                'assets/icons/nav_back.png',
                              ),
                              width: 18,
                              height: 18,
                              color: ZzColor.blackColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text("验证码登录", style: ZzFonts.fontMedium333(24)),
                  const SizedBox(height: 10),
                  Text("新号码登录自动注册账号", style: ZzFonts.fontNormal999(14)),

                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        height: 50,
                        decoration: ZzDecoration.withborder(
                          ZzColor.whiteColor,
                          0.3,
                          ZzColor.mainAppColor,
                          radius: 5,
                        ),
                        child: TextField(
                          focusNode: phoneNode,
                          controller: _phoneEditingController,
                          cursorColor: ZzColor.mainAppColor, // 设置光标颜色为红色
                          style: ZzFonts.fontMedium111(14),
                          textAlign: TextAlign.start,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 20),
                            isDense: true,
                            border: InputBorder.none,
                            hintText: "请输入手机号",
                            hintStyle: ZzFonts.fontNormal666(15),
                          ),
                          onChanged: (value) {
                            if (value.length >= 11) {
                              setState(() {
                                if (ZzString.isPhoneNum(value)) {
                                  _phoneInputStutas = PhoneInputStutas.inputend;
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(FocusNode());
                                } else {
                                  _phoneInputStutas = PhoneInputStutas.inputerr;
                                }
                              });
                            } else if (value.isEmpty) {
                              setState(() {
                                _phoneInputStutas = PhoneInputStutas.waitinput;
                              });
                            } else {
                              setState(() {
                                _phoneInputStutas = PhoneInputStutas.inputing;
                              });
                            }
                          },
                        ),
                      ),
                      _phoneInputStutas != PhoneInputStutas.waitinput
                          ? Positioned(
                              right: 20,
                              child: InkWell(
                                onTap: () {
                                  _phoneEditingController.text = "";
                                  setState(() {
                                    _phoneInputStutas =
                                        PhoneInputStutas.waitinput;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Image.asset(
                                    width: 20.0,
                                    height: 20.0,
                                    "assets/login/login_clear_input.png",
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),

                  InkWell(
                    onTap: () => _loginButtomDidChange(),
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      height: 50,
                      decoration: _phoneInputStutas == PhoneInputStutas.inputend
                          ? ZzDecoration.onlyradius(100, ZzColor.mainAppColor)
                          : ZzDecoration.onlyradius(100, ZzColor.colorToFFF1EB),
                      child: Text("验证码登录", style: ZzFonts.fontBoldWhite(15)),
                    ),
                  ),

                  // Visibility(
                  //   visible: _supportOneClickLogin,
                  //   child: InkWell(
                  //     onTap: () {
                  //       _loginAuto();
                  //     },
                  //     child: Container(
                  //       padding: EdgeInsets.all(15),
                  //       child: Center(child: Text("一键登录")),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Positioned(bottom: 0, child: _getProtocolWidget()),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog() {
    ZzCustomDialog.show(
      context: context,
      image: Positioned(
        top: -75,
        left: 0,
        right: 0,
        child: Image.asset('assets/images/lingdang.png', height: 150),
      ),
      customContent: Column(
        children: [
          Text("登录前请阅读并同意", style: ZzFonts.fontMedium333(15)),
          SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: const TextStyle(color: ZzColor.color_93A1AA, fontSize: 15),

              children: [
                TextSpan(
                  text: "《服务协议》",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      safePushToPage(
                        context,
                        'base_webview_page',
                        arguments: {
                          "url": "${BaseUrl.webUrl}/contracts/agreement",
                          "title": '服务协议',
                        },
                      );
                    },
                  style: const TextStyle(color: ZzColor.color_0A81DE),
                ),
                const TextSpan(text: "和"),
                TextSpan(
                  text: "《隐私政策》",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      safePushToPage(
                        context,
                        'base_webview_page',
                        arguments: {
                          "url": "${BaseUrl.webUrl}/contracts/privacy-policy",
                          "title": '隐私政策',
                        },
                      );
                    },
                  style: const TextStyle(color: ZzColor.color_0A81DE),
                ),
              ],
            ),
            softWrap: true, // 允许文本自动换行
            overflow: TextOverflow.clip, // 溢出时剪切文本
          ),
        ],
      ),
      leftButtonText: "不同意",
      rightButtonText: "同意",
      rightButtonAction: () {
        setState(() {
          _isAgreeProtocol = true;
        });
        safeGoback(context);
        _loginButtomDidChange();
      },
    );
  }

  Widget _getProtocolWidget() {
    return Container(
      padding: EdgeInsets.only(
        bottom: 35 + ZzScreen().paddingBottom,
        right: 20,
        left: 15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isAgreeProtocol = !_isAgreeProtocol;
              });
            },
            child: Container(
              //  color: Colors.red,
              height: 50,
              width: 40,
              padding: const EdgeInsets.only(left: 11, right: 11),
              child: Image.asset(
                !_isAgreeProtocol
                    ? "assets/login/login_select_false.png"
                    : "assets/login/login_select_true.png",
                width: 18,
                height: 18,
              ),
            ),
          ),
          Container(
            width: ZzScreen().screenWidth - 75,
            child: buildShakeAnimationWidget(
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: ZzColor.color_93A1AA,
                    fontSize: 12,
                  ),
                  children: [
                    const TextSpan(text: "我已阅读并同意"),
                    TextSpan(
                      text: "《服务协议》",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          safePushToPage(
                            context,
                            'base_webview_page',
                            arguments: {
                              "url": "${BaseUrl.webUrl}/contracts/agreement",
                              "title": '服务协议',
                            },
                          );
                        },
                      style: const TextStyle(color: ZzColor.color_0A81DE),
                    ),
                    const TextSpan(text: "和"),
                    TextSpan(
                      text: "《隐私政策》",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          safePushToPage(
                            context,
                            'base_webview_page',
                            arguments: {
                              "url":
                                  "${BaseUrl.webUrl}/contracts/privacy-policy",
                              "title": '隐私政策',
                            },
                          );
                        },
                      style: const TextStyle(color: ZzColor.color_0A81DE),
                    ),
                  ],
                ),
                softWrap: true, // 允许文本自动换行
                overflow: TextOverflow.clip, // 溢出时剪切文本
              ),
            ),
          ),
        ],
      ),
    );
  }

  //获取短信验证码
  _loginButtomDidChange() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_phoneInputStutas != PhoneInputStutas.inputend) {
      return;
    }
    if (!_isAgreeProtocol) {
      // ZzLoading.showMessage("请仔细阅读并同意服务协议");
      _shakeAnimationController.start(shakeCount: 1);
      _showConfirmDialog();
      return;
    }

    _getCodefromPhoneUrl();
  }

  _getCodefromPhoneUrl() {
    ZzLoading.show();
    HttpUtil.getInstance().get(
      "/user/loginWhitelist",
      queryParameters: {"mobile": _phoneEditingController.text},
      successCallback: (data) {
        ZzLoading.dismiss();
        if (data == true) {
          safePushToPage(
            context,
            "login_code_page",
            arguments: {
              "phoneNum": _phoneEditingController.text,
              "saveCallBack": (Map data) {},
            },
          );
        } else {
          _getCode();
        }
      },
      errorCallback: (errorCode, errorMsg) {
        _getCode();
      },
    );
  }

  _getCode() {
    ZzLoading.show();
    HttpUtil.getInstance().get(
      "/user/sendCode",
      queryParameters: {"mobile": _phoneEditingController.text},
      successCallback: (data) {
        ZzLoading.dismiss();
        safePushToPage(
          context,
          "login_code_page",
          arguments: {
            "phoneNum": _phoneEditingController.text,
            "saveCallBack": (Map data) {},
          },
        );
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage("短信发送失败$errorMsg");
      },
    );
  }

  //申请登录
  //申请登录
  _postCodetoLoginUrl(autoToken) {
    ZzLoading.show();

    HttpUtil.getInstance().post(
      "/user/loginOrRegister",
      data: {"autoToken": autoToken, "loginType": "AUTO"},
      successCallback: (data) {
        BaseSpStorage.getInstance().setUserToken(data["userToken"] ?? "");
        _logingSuccess();
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage("$errorMsg");
      },
    );
  }

  _logingSuccess() {
    HttpUtil.cleariInstance(); //重置网络配置
    BaseSpStorage.getInstance().updateUserInfo();
    ZzLoading.dismiss();
    //发送登录成功通知
    zzEventBus.fire(LoginBus(true));
    // 延时半秒执行返回
    Future.delayed(const Duration(milliseconds: 500), () {
      _aliyunPush.bindAccount(BaseSpStorage.getInstance().mobile).then((
        bindResult,
      ) {
        var code = bindResult['code'];
        if (code == kAliyunPushSuccessCode) {
          debugPrint('绑定阿里云成功${BaseSpStorage.getInstance().mobile}');
        } else {
          debugPrint('绑定阿里云失败${bindResult["errorMsg"]}');
        }
      });
      if (Platform.isAndroid) {
        _aliyunPush.bindPhoneNumber(BaseSpStorage.getInstance().mobile).then((
          bindResult,
        ) {
          var code = bindResult['code'];
          if (code == kAliyunPushSuccessCode) {
            debugPrint('绑定阿里云成功${BaseSpStorage.getInstance().mobile}');
          } else {
            debugPrint('绑定阿里云失败${bindResult["errorMsg"]}');
          }
        });
      }
      // var storage = BaseSpStorage.getInstance();//有没有登录后需要更新的本地配置
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }
}
