import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/tools/ZzCustomDialog.dart';
import 'package:zhijin_compass/ztool/ztool_popup.dart';

import '../../../ztool/ztool.dart';
//在启动页获取后台返回的欢迎页数据-存至本地下次打开展示以维护正确欢迎页体验
//封禁流程在首页处理

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List<Widget> _images = [];
  Timer? _timer;
  int _countdown = 0;
  final int _singleTime = 3;
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    // print("HHHHHH--进入欢迎页面");
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () async {
        _showProView();
      });
    });
  }

  _showProView() {
    // 在当前帧绘制完成后执行的操作
    // 例如，执行一些需要等到UI渲染完成后才能进行的操作

    String isareeprol = BaseSpStorage.getInstance().isAgreeProl;
    print("操作前${BaseSpStorage.getInstance().isAgreeProl}");
    if (isareeprol != "true") {
      if (isareeprol == "false") {
        // _showSecondView();
        _showFirstView();
      } else {
        _showFirstView();
      }
    } else {
      _startShowBanners();
    }
  }

  _showFirstView() {
    ZzCustomDialog.show(
      title: "欢迎使用智金罗盘",
      context: context,
      customContent: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "感谢您使用智金罗盘，我们依据相关法律制定了",
                    style: TextStyle(
                      letterSpacing: 1.1,
                      height: 1.4,
                      color: ZzColor.color_333333,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: "《用户服务协议》",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        safePushToPage(
                          context,
                          'base_webview_page',
                          arguments: {
                            "url": "${BaseUrl.webUrl}/contracts/agreement",
                            "title": "用户服务协议",
                          },
                        );
                      },
                    style: TextStyle(
                      letterSpacing: 1.1,
                      height: 1.4,
                      color: ZzColor.mainAppColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const TextSpan(
                    text: "和",
                    style: TextStyle(
                      letterSpacing: 1.1,
                      height: 1.4,
                      color: ZzColor.color_333333,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: "《个人信息保护协议》",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        safePushToPage(
                          context,
                          'base_webview_page',
                          arguments: {
                            "url": "${BaseUrl.webUrl}/contracts/privacy-policy",
                            "title": "个人信息保护协议",
                          },
                        );
                      },
                    style: TextStyle(
                      letterSpacing: 1.1,
                      height: 1.4,
                      color: ZzColor.mainAppColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const TextSpan(
                    text:
                        "，请您在点击同意之前仔细阅读并充分理解相关条款，方便您了解自己的权利。如果您同意，请点击下方按钮开始接受我们的服务。",
                    style: TextStyle(
                      letterSpacing: 1.1,
                      height: 1.4,
                      color: ZzColor.color_333333,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  // const TextSpan(
                  //   text:
                  //       "\n\n1、为向您提供内容展示、交易相关基本功能，我们会收集、使用必要的信息；\n\n2、基于您的明示授权，我们可能会获取您的位置(为您展示您附近的任务信息、任务地址导航等)、设备信息(用于表示您的身份，为您提供服务，存储您的接单信息等以保障您账号与交易安全)，存储权限（用于缓存图片、降低流量消耗），您有权拒绝或取消授权；\n\n3、我们会采取业界先进的安全措施保护您的信息安全；\n\n4、未经您同意，我们不会从第三方处获取、共享或向其提供您的信息；\n\n5、您可以查询、更正、删除您的个人信息，我们也提供账户注销的渠道。以上修改具体以政策内容为准。若您不赞同，请选择不同意。",
                  //   style: TextStyle(
                  //     letterSpacing: 1.1,
                  //     height: 1.4,
                  //     color: ZzColor.color_666666,
                  //     fontWeight: FontWeight.normal,
                  //     fontSize: 12,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
      leftButtonText: "拒绝",
      rightButtonText: "同意并继续",
      leftButtonAction: () {
        BaseSpStorage.getInstance().setIsAreeProl("false");
        Future.delayed(const Duration(milliseconds: 500), () async {
          exit(0);
        });
      },
      rightButtonAction: () {
        BaseSpStorage.getInstance().setIsAreeProl("true");
        Navigator.of(context).pushNamedAndRemoveUntil(
          "index_page",
          (Route<dynamic> route) => false,
        );
      },
    );
    return;
    ZzPopupView.showPopupViewOfIOS(
      context,
      barrierDismissible: false,
      title: "欢迎使用智金罗盘",
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "感谢您使用智金罗盘，我们依据相关法律制定了",
                  style: TextStyle(
                    letterSpacing: 1.1,
                    height: 1.4,
                    color: ZzColor.color_333333,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: "《用户服务协议》",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      safePushToPage(
                        context,
                        'base_webview_page',
                        arguments: {
                          "url": "${BaseUrl.webUrl}/contracts/agreement",
                          "title": "用户服务协议",
                        },
                      );
                    },
                  style: TextStyle(
                    letterSpacing: 1.1,
                    height: 1.4,
                    color: ZzColor.mainAppColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const TextSpan(
                  text: "和",
                  style: TextStyle(
                    letterSpacing: 1.1,
                    height: 1.4,
                    color: ZzColor.color_333333,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: "《个人信息保护协议》",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      safePushToPage(
                        context,
                        'base_webview_page',
                        arguments: {
                          "url": "${BaseUrl.webUrl}/contracts/privacy-policy",
                          "title": "个人信息保护协议",
                        },
                      );
                    },
                  style: TextStyle(
                    letterSpacing: 1.1,
                    height: 1.4,
                    color: ZzColor.mainAppColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const TextSpan(
                  text:
                      "，请您在点击同意之前仔细阅读并充分理解相关条款，方便您了解自己的权利。如果您同意，请点击下方按钮开始接受我们的服务。",
                  style: TextStyle(
                    letterSpacing: 1.1,
                    height: 1.4,
                    color: ZzColor.color_333333,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                // const TextSpan(
                //   text:
                //       "\n\n1、为向您提供内容展示、交易相关基本功能，我们会收集、使用必要的信息；\n\n2、基于您的明示授权，我们可能会获取您的位置(为您展示您附近的任务信息、任务地址导航等)、设备信息(用于表示您的身份，为您提供服务，存储您的接单信息等以保障您账号与交易安全)，存储权限（用于缓存图片、降低流量消耗），您有权拒绝或取消授权；\n\n3、我们会采取业界先进的安全措施保护您的信息安全；\n\n4、未经您同意，我们不会从第三方处获取、共享或向其提供您的信息；\n\n5、您可以查询、更正、删除您的个人信息，我们也提供账户注销的渠道。以上修改具体以政策内容为准。若您不赞同，请选择不同意。",
                //   style: TextStyle(
                //     letterSpacing: 1.1,
                //     height: 1.4,
                //     color: ZzColor.color_666666,
                //     fontWeight: FontWeight.normal,
                //     fontSize: 12,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
      leftBtnTitle: "拒绝",
      rightBtnTitle: "同意并继续",
      onLeftBtnCallBack: () {
        BaseSpStorage.getInstance().setIsAreeProl("false");
        print("操作后${BaseSpStorage.getInstance().isAgreeProl}");
        Future.delayed(const Duration(milliseconds: 500), () async {
          exit(0);
        });
      },
      onRightBtnCallBack: () {
        BaseSpStorage.getInstance().setIsAreeProl("true");
        Navigator.of(context).pushNamedAndRemoveUntil(
          "index_page",
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  oneshowtwo() {
    BaseSpStorage.getInstance().setIsAreeProl("false");
    Future.delayed(const Duration(milliseconds: 200), () async {
      _showSecondView();
    });
  }

  _showSecondView() {
    ZzPopupView.showPopupViewOfIOS(
      context,
      barrierDismissible: false,
      title: "重要提示",
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: "进入应用前，您需先同意",
              style: TextStyle(
                letterSpacing: 1.1,
                height: 1.4,
                color: ZzColor.color_333333,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            TextSpan(
              text: "《用户协议》",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  safePushToPage(
                    context,
                    "protocol_webview_page",
                    arguments: {
                      "url": "https://api.zgjinding.cn/content.html?id=5",
                      "title": "用户协议",
                      "isNeedAppBar": true,
                    },
                  );
                },
              style: TextStyle(
                letterSpacing: 1.1,
                height: 1.4,
                color: ZzColor.mainAppColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const TextSpan(
              text: "和",
              style: TextStyle(
                letterSpacing: 1.1,
                height: 1.4,
                color: ZzColor.color_333333,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            TextSpan(
              text: "《隐私政策》",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  safePushToPage(
                    context,
                    "protocol_webview_page",
                    arguments: {
                      "url": "https://api.zgjinding.cn/content.html?id=4",
                      "title": "隐私政策",
                      "isNeedAppBar": true,
                    },
                  );
                },
              style: TextStyle(
                letterSpacing: 1.1,
                height: 1.4,
                color: ZzColor.mainAppColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const TextSpan(
              text: "，否则将退出应用，如果您同意，请点击下方按钮开始接受我们的服务。",
              style: TextStyle(
                letterSpacing: 1.1,
                height: 1.4,
                color: ZzColor.color_333333,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      leftBtnTitle: "退出",
      rightBtnTitle: "同意并继续",
      onLeftBtnCallBack: () {
        BaseSpStorage.getInstance().setIsAreeProl("false");
        print("操作后${BaseSpStorage.getInstance().isAgreeProl}");
        Future.delayed(const Duration(milliseconds: 500), () async {
          exit(0);
        });
      },
      onRightBtnCallBack: () {
        BaseSpStorage.getInstance().setIsAreeProl("true");
        Navigator.of(context).pushNamedAndRemoveUntil(
          "index_page",
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  _startShowBanners() {
    List advertisingList = BaseSpStorage.getInstance().advertisingList;
    print("打印广告页数据1==${advertisingList.length}");
    if (advertisingList.isNotEmpty) {
      _images = [];
      for (var element in advertisingList) {
        //提前将图片加载到内存中
        precacheImage(NetworkImage(element["imageUrl"]), context);

        var imageWidget = Image.network(
          element["imageUrl"],
          width: ZzScreen().screenWidth,
          height: ZzScreen().screenHeight,
          fit: BoxFit.cover,
        );

        _images.add(imageWidget);
      }
      _countdown = _images.length * _singleTime;
      if (_countdown < 4) {
        _countdown = 4;
      }
    } else {
      _countdown = 2;
    }
    startCountdown();
    BaseSpStorage.getInstance().getadvertisingDataUrl();
  }

  void startCountdown() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if (_countdown < 1) {
          timer.cancel();
          Navigator.of(context).pushNamedAndRemoveUntil(
            "index_page",
            (Route<dynamic> route) => false,
          );
        } else {
          _countdown -= 1;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZzScreen().setContent(context);
    return _buildWelComeWidget();
  }

  _buildWelComeWidget() {
    return Stack(
      children: [
        Image.asset(
          "assets/images/auto_bg.png",
          width: ZzScreen().screenWidth,
          height: ZzScreen().screenHeight,
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}
