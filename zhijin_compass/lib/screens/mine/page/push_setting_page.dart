import 'dart:async';

import 'package:aliyun_push/aliyun_push.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:jpush_flutter/jpush_flutter.dart';
// import 'package:jpush_flutter/jpush_interface.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/roots/root_event_bus.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/storages/user_model.dart';
import 'package:zhijin_compass/tools/ZzPermissionTool.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'package:zhijin_compass/ztool/ztool_appbar.dart';

class PushSettingPage extends StatefulWidget {
  const PushSettingPage({super.key});

  @override
  State<PushSettingPage> createState() => _PushSettingPageState();
}

class _PushSettingPageState extends State<PushSettingPage>
    with LifecycleAware, LifecycleMixin {
  bool _isPushAble = false;
  UserModel? _userModel;

  late StreamSubscription<UserInfoUpDateBus> _updateInfoStream;
  // final JPushFlutterInterface jpush = JPush.newJPush();
  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.active) {
      _getPushStatus();
    }
  }

  _getPushStatus() async {
    final status = await ZzPermissionTool().checkPermission(
      PermissionType.notification,
    );

    if (status.isGranted) {
      setState(() {
        _isPushAble = true;
      });
      // 已有权限则直接返回
    } else {
      setState(() {
        _isPushAble = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _userModel = BaseSpStorage.getInstance().userModel;
    _getPushStatus();
    _updateInfoStream = zzEventBus.on<UserInfoUpDateBus>().listen((event) {
      if (mounted) {
        setState(() {
          _userModel = event.model;
        });
      }
    });
  }

  _setSystemPush() {
    if ($empty(BaseSpStorage.getInstance().userToken)) {
      safePushToPage(context, 'login_page');
      return;
    }
    // ZzLoading.show();
    HttpUtil.getInstance().post(
      "/user/updateUserInfo",
      data: {"pushSystemMessage": !(_userModel!.pushSystemMessage ?? false)},
      successCallback: (data) {
        BaseSpStorage.getInstance().updateUserInfo();
        // ZzLoading.dismiss();
      },
      errorCallback: (code, message) {
        ZzLoading.showMessage(message);
      },
    );
  }

  @override
  void dispose() {
    _updateInfoStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZzColor.pageBackGround,
      appBar: ZzAppBar(title: "推送设置"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 8),
              Visibility(
                visible: !_isPushAble,
                child: Container(
                  decoration: BoxDecoration(
                    //渐变色
                    gradient: LinearGradient(
                      colors: [Color(0xffFFF3DD), Color(0xffFFFCF7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),

                    //边框
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/lingdang_small.png',
                            height: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "开启推送通知，不错过任何重要消息",
                            style: ZzFonts.fontNormal333(14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: ZzColor.whiteColor,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("允许推送", style: ZzFonts.fontNormal333(14)),
                    CupertinoSwitch(
                      value: _isPushAble,
                      onChanged: (value) {
                        if (_isPushAble) {
                          AliyunPush().jumpToAndroidNotificationSettings();
                        } else {
                          showPushPermissDialog(
                            context,
                            mounted,
                            onGranted: () {
                              _getPushStatus();
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 15, top: 30),
                child: Text("推送消息", style: ZzFonts.fontMedium111(14)),
              ),
              Container(
                color: _isPushAble
                    ? ZzColor.whiteColor
                    : const Color.fromARGB(113, 255, 255, 255),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("系统消息", style: ZzFonts.fontNormal333(14)),
                    CupertinoSwitch(
                      value:
                          ((_userModel?.pushSystemMessage ?? false) &&
                          _isPushAble),
                      onChanged: (value) {
                        if (_isPushAble) {
                          _setSystemPush();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
