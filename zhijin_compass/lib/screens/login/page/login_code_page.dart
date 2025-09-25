import 'dart:async';
import 'dart:io';

import 'package:aliyun_push/aliyun_push.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/roots/root_event_bus.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'package:uuid/uuid.dart';

typedef saveCallback = void Function(Map);

class LoginCodePage extends StatefulWidget {
  final saveCallback? saveCallBack;
  final String phoneNum;
  const LoginCodePage({
    super.key,
    required this.phoneNum,
    required this.saveCallBack,
  });

  @override
  State<LoginCodePage> createState() => _LoginCodePageState();
}

class _LoginCodePageState extends State<LoginCodePage> {
  final uuid = Uuid();
  final _aliyunPush = AliyunPush();
  late TextEditingController _codeEditingController;
  late TextEditingController _inviteEditingController;
  bool _isGetVerificationAgain = false; //是否可以重新发送
  bool _isNewUser = false; //是否新用户
  bool _isInputDone = false; //是否可以重新发送
  var _seconds = 60;
  int _codeLength = 6;
  Timer? _countdownTimer;
  final storage = BaseSpStorage.getInstance();
  @override
  void initState() {
    super.initState();
    _codeEditingController = TextEditingController();
    _codeEditingController.text = "";
    _inviteEditingController = TextEditingController();
    _startCountdownMethod();
    _getIsNewUserUrl();
  }

  //开始倒计时
  _startCountdownMethod() {
    if (_countdownTimer != null) {
      return;
    }
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 1) {
          _seconds--;
        } else {
          _countdownTimer?.cancel();
          _countdownTimer = null;
          _isGetVerificationAgain = true;
        }
      });
    });
  }

  _getVerificationCode() {
    if (!_isGetVerificationAgain) {
      return;
    }
    HttpUtil.getInstance().get(
      "/user/sendCode",
      queryParameters: {"mobile": widget.phoneNum},
      successCallback: (data) {
        ZzLoading.showMessage("短信发送成功");
        _isGetVerificationAgain = false;
        _seconds = 60;
        _startCountdownMethod();
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage("$errorMsg");
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return inputWidget(
      context,
      Container(
        color: ZzColor.whiteColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 100.0.rpxH),
                child: Text("请输入短信验证码", style: ZzFonts.fontBold333(30)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  "验证码已发送至${ZzString.obscureStr(str: widget.phoneNum, start: 3, len: 4)}",
                  style: ZzFonts.fontBold666(14),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 50),
                margin: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //密码输入框
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        decoration: ZzDecoration.onlyradius(
                          5,
                          ZzColor.lineColor,
                        ),
                        child: TextField(
                          controller: _codeEditingController,

                          style: ZzFonts.fontMedium111(14),
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(_codeLength),
                          ],
                          keyboardType: TextInputType.phone,
                          cursorColor: ZzColor.mainAppColor, // 设置光标颜色为红色
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: "请输入验证码",
                            hintStyle: ZzFonts.fontNormal999(15),
                          ),
                          onChanged: (text) {
                            setState(() {
                              if (text.length >= _codeLength) {
                                _isInputDone = true;
                              } else {
                                _isInputDone = false;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _getVerificationCode(),
                      child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: ZzDecoration.withborder(
                          ZzColor.whiteColor,
                          1,
                          ZzColor.mainAppColor,
                          radius: 5,
                        ),
                        child: Center(
                          child: Text(
                            _isGetVerificationAgain
                                ? "重新获取"
                                : "$_seconds秒后重新获取",
                            style: ZzFonts.fontMediumMain(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _isNewUser
                  ? Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 20,
                      ),
                      height: 50,
                      decoration: ZzDecoration.onlyradius(5, ZzColor.lineColor),
                      child: TextField(
                        controller: _inviteEditingController,
                        cursorColor: ZzColor.mainAppColor, // 设置光标颜色为红色
                        style: ZzFonts.fontMedium111(14),
                        textAlign: TextAlign.center,

                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: "请输入好友的邀请码(选填)",
                          hintStyle: ZzFonts.fontNormal999(15),
                        ),
                      ),
                    )
                  : Container(),
              InkWell(
                onTap: () => _postCodetoLoginUrl(),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 40,
                  ),
                  height: 50,
                  decoration: _isInputDone
                      ? ZzDecoration.onlyradius(5, ZzColor.mainAppColor)
                      : ZzDecoration.onlyradius(5, ZzColor.colorToFFF1EB),
                  child: Center(
                    child: Text("完成", style: ZzFonts.fontBoldWhite(15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //获取是否是新用户
  _getIsNewUserUrl() {
    // HttpUtil.getInstance().get(
    //   "/work-api/work/api/commons/check/phone",
    //   queryParameters: {"phone": widget.phoneNum},
    //   successCallback: (data) {
    //     String check = "$data";
    //     if (check == "0") {
    //       setState(() {
    //         _isNewUser = true;
    //       });
    //     }
    //   },
    //   errorCallback: (errorCode, errorMsg) {},
    // );
  }

  //申请登录
  _postCodetoLoginUrl() {
    if (_codeEditingController.text.length < _codeLength) {
      return;
    }
    ZzLoading.show();

    HttpUtil.getInstance().post(
      "/user/loginOrRegister",
      data: {
        "mobile": widget.phoneNum,
        "verifyCode": _codeEditingController.text,
        "loginType": "SMS",
        "deviceId": storage.deviceId,
      },
      successCallback: (data) {
        storage.setUserToken(data["userToken"] ?? "");

        _logingSuccess();
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage("$errorMsg");
      },
    );
  }

  _logingSuccess() {
    HttpUtil.cleariInstance(); //重置网络配置
    storage.updateUserInfo();
    ZzLoading.dismiss();
    //发送登录成功通知
    zzEventBus.fire(LoginBus(true));

    // 延时半秒执行返回
    Future.delayed(const Duration(milliseconds: 500), () {
      _aliyunPush.bindAccount(widget.phoneNum).then((bindResult) {
        var code = bindResult['code'];
        if (code == kAliyunPushSuccessCode) {
          debugPrint('绑定阿里云成功${widget.phoneNum}');
        } else {
          debugPrint('绑定阿里云失败${bindResult["errorMsg"]}');
        }
      });
      if (Platform.isAndroid) {
        _aliyunPush.bindPhoneNumber(widget.phoneNum).then((bindResult) {
          var code = bindResult['code'];
          if (code == kAliyunPushSuccessCode) {
            debugPrint('绑定阿里云成功${widget.phoneNum}');
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
