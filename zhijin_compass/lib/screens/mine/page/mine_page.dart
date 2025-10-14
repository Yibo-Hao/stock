import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:aliyun_push/aliyun_push.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/mine/utils/cache_utils.dart';
import 'package:zhijin_compass/screens/mine/widget/menu_item_widget.dart';
import 'package:zhijin_compass/screens/roots/root_event_bus.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/tools/ZzCustomDialog.dart';

import 'package:zhijin_compass/ztool/ztool.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with LifecycleAware, LifecycleMixin {
  bool _isLogin = false;
  final _aliyunPush = AliyunPush();
  var _count = 0;
  late StreamSubscription<TabbarOnChangeBus> updateDataStream;
  String _cacheSize = '';
  @override
  void initState() {
    super.initState();
    _isLogin = BaseSpStorage.getInstance().userToken.isNotEmpty;
    updateDataStream = zzEventBus.on<TabbarOnChangeBus>().listen((event) {
      debugPrint('mine page${event.index}');
      if (mounted && event.index == 2) {
        setState(() {
          _isLogin = BaseSpStorage.getInstance().userToken.isNotEmpty;
          _getCacheSize();
        });
      }
    });
    _getCacheSize();
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.active) {
      setState(() {
        _isLogin = BaseSpStorage.getInstance().userToken.isNotEmpty;
        _getCacheSize();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ZzScreen().setContent(context);
    return Scaffold(
      backgroundColor: ZzColor.color_FFF7F7F7,
      body: Container(
        //设置背景视图,上面有个80高的色块
        decoration: const BoxDecoration(color: ZzColor.pageBackGround),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/mine_bg.png',
                width: double.infinity,
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: ZzScreen().paddingTop + 20,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if ($notempty(
                                    BaseSpStorage.getInstance().userToken,
                                  )) {
                                  } else {
                                    safePushToPage(context, "login_page");
                                  }
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/mine_avatar.png',
                                      height: 70,
                                    ),
                                    SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isLogin
                                              ? "智选${ZzString.getLastFourChars(BaseSpStorage.getInstance().mobile, 4)}"
                                              : "请登录",
                                          style: ZzFonts.fontMedium111(18),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          _isLogin
                                              ? ZzString.obscureStr(
                                                  str:
                                                      BaseSpStorage.getInstance()
                                                          .mobile,
                                                  start: 3,
                                                  len: 4,
                                                )
                                              : '登录后查看更多信息',
                                          style: ZzFonts.fontNormal666(14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if ($notempty(
                                    BaseSpStorage.getInstance().userToken,
                                  )) {
                                    safePushToPage(context, "message_page");
                                  } else {
                                    safePushToPage(context, "login_page");
                                  }
                                },
                                child: Badge(
                                  textColor: ZzColor.whiteColor,
                                  label: _count > 1
                                      ? Text(_count > 99 ? "99+" : "$_count")
                                      : null,
                                  offset: Offset(-1, 1),
                                  isLabelVisible: _count > 0,
                                  child: Image.asset(
                                    'assets/images/mine_message.png',
                                    height: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: ZzDecoration.onlyradius(
                            8,
                            ZzColor.whiteColor,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/banner_wait.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Container(
                        //   padding: EdgeInsets.symmetric(
                        //     horizontal: 15,
                        //     vertical: 10,
                        //   ),
                        //   margin: EdgeInsets.symmetric(
                        //     horizontal: 20,
                        //     vertical: 10,
                        //   ),
                        //   decoration: ZzDecoration.onlyradius(
                        //     8,
                        //     ZzColor.whiteColor,
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text("我的交易账户", style: ZzFonts.fontNormal333(16)),
                        //       SizedBox(height: 10),
                        //       Container(
                        //         height: 100,
                        //         decoration: ZzDecoration.onlyradius(
                        //           5,
                        //           ZzColor.pageBackGround,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: ZzDecoration.onlyradius(
                            8,
                            ZzColor.whiteColor,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 8),
                              MenuItemWidget(
                                iconPath: 'assets/images/mine_push.png',
                                title: '推送设置',
                                onTap: () {
                                  // 推送设置点击事件
                                  safePushToPage(context, 'push_settings_page');
                                },
                              ),
                              MenuItemWidget(
                                iconPath: 'assets/images/mine_permission.png',
                                title: '系统权限管理',
                                onTap: () {
                                  // 系统权限管理点击事件
                                  openAppSettings();
                                },
                              ),
                              MenuItemWidget(
                                isEnd: true,
                                iconPath: 'assets/images/mine_clean.png',
                                title: '清除缓存',
                                trailingText: _cacheSize,
                                onTap: _showClearCacheDialog,
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: ZzDecoration.onlyradius(
                            8,
                            ZzColor.whiteColor,
                          ),
                          child: Column(
                            children: [
                              MenuItemWidget(
                                iconPath: 'assets/images/mine_serve.png',
                                title: '联系客服',
                                onTap: () {
                                  // 联系客服点击事件
                                  safePushToPage(
                                    context,
                                    'customer_service_page',
                                  );
                                },
                              ),
                              MenuItemWidget(
                                isEnd: true,
                                iconPath: 'assets/images/mine_about.png',
                                title: '关于我们',
                                onTap: () {
                                  // 关于我们点击事件
                                  safePushToPage(context, 'about_page');
                                },
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: _isLogin,
                          child: InkWell(
                            onTap: () {
                              _loginOut();
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                top: 8,
                                left: 20,
                                right: 20,
                              ),
                              height: 45,
                              decoration: ZzDecoration.onlyradius(
                                100,
                                ZzColor.whiteColor,
                              ),
                              child: Center(
                                child: Text(
                                  "安全退出",
                                  style: ZzFonts.fontNormal111(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 获取缓存大小
  _getCacheSize() async {
    if ($notempty(BaseSpStorage.getInstance().userToken)) {
      HttpUtil.getInstance().get(
        "/message/getUnReadMessageNum",
        successCallback: (data) {
          setState(() {
            _count = data ?? 0;
          });
        },
        errorCallback: (errorCode, errorMsg) {
          ZzLoading.showMessage(errorMsg);
        },
      );
    } else {
      setState(() {
        _count = 0;
      });
    }

    try {
      final size = await CacheUtils.getCacheSize();
      setState(() {
        debugPrint('缓存大小：$size');
        _cacheSize = CacheUtils.formatSize(size);
      });
    } catch (e) {
      setState(() {
        debugPrint('缓存大小获取失败：$e');
        _cacheSize = "";
      });
    }
  }

  // 显示清除缓存对话框
  void _showClearCacheDialog() {
    ZzCustomDialog.show(
      context: context,
      image: Positioned(
        top: -75,
        left: 0,
        right: 0,
        child: Image.asset('assets/images/mine_clear.png', height: 150),
      ),
      content:
          (!_isLogin && $notempty(BaseSpStorage.getInstance().localStockModels))
          ? "清理缓存将会清空自选股,确定要清除缓存?"
          : '确定要清除缓存?',
      leftButtonText: "取消",
      rightButtonText: "清除",
      rightButtonAction: () {
        _clearCache();
        BaseSpStorage.getInstance().cleanLocalStockList();
        safeGoback(context);
      },
    );
  }

  // 清除缓存
  void _clearCache() async {
    ZzLoading.show();
    try {
      await CacheUtils.clearCache();
      await CachedNetworkImageProvider.defaultCacheManager.emptyCache();

      //延迟一秒执行
      Future.delayed(Duration(milliseconds: 1000), () {
        ZzLoading.showMessage("缓存已清除");
        setState(() {
          _cacheSize = "";
        });
      });
    } catch (e) {
      ZzLoading.showMessage("清除缓存失败");
    }
  }

  _loginOut() {
    ZzCustomDialog.show(
      context: context,
      image: Positioned(
        top: -75,
        left: 0,
        right: 0,
        child: Image.asset('assets/images/dialog_warnning.png', height: 150),
      ),
      content: '确定退出当前账号吗?',
      leftButtonText: "取消",

      rightButtonText: "退出",
      rightButtonAction: () {
        safeGoback(context);
        //延迟半秒
        Future.delayed(Duration(milliseconds: 500), () {
          _loginOutUrl();
        });
      },
    );
  }

  void _loginOutUrl() {
    ZzLoading.show();
    HttpUtil.getInstance().post(
      "/user/logOut",
      successCallback: (data) {
        _logOutSuccess();
      },
      errorCallback: (errorCode, errorMsg) {
        _logOutSuccess();
      },
    );
  }

  void _logOutSuccess() {
    ZzLoading.dismiss();
    setState(() {
      _isLogin = false;
      _count = 0;
    });
    _aliyunPush.unbindAccount().then((unbindResult) {
      var code = unbindResult['code'];
      if (code == kAliyunPushSuccessCode) {
        debugPrint('解绑阿里云成功${BaseSpStorage.getInstance().mobile}');
      } else {
        debugPrint('解绑阿里云失败${unbindResult["errorMsg"]}');
      }
    });
    if (Platform.isAndroid) {
      _aliyunPush.unbindPhoneNumber().then((unbindResult) {
        var code = unbindResult['code'];
        if (code == kAliyunPushSuccessCode) {
          debugPrint('解绑阿里云成功${BaseSpStorage.getInstance().mobile}');
        } else {
          debugPrint('解绑阿里云失败${unbindResult["errorMsg"]}');
        }
      });
    }
    zzEventBus.fire(LoginBus(false));
    BaseSpStorage.getInstance().setUserModel(null);
    BaseSpStorage.getInstance().setUserToken("");
    HttpUtil.cleariInstance();
  }
}
