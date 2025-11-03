import 'dart:async';
import 'dart:io';

import 'package:aliyun_push/aliyun_push.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
// import 'package:jpush_flutter/jpush_flutter.dart';
// import 'package:jpush_flutter/jpush_interface.dart';
import 'package:zhijin_compass/screens/deal/page/deal_page.dart';
import 'package:zhijin_compass/screens/home/page/home_page.dart';
import 'package:zhijin_compass/screens/mine/page/mine_page.dart';
import 'package:zhijin_compass/screens/roots/root_event_bus.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'package:uuid/uuid.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

// import 'package:yuyou_trucks/screens/navigate/pages/navigate.dart';
// import 'package:yuyou_trucks/screens/task/pages/task.dart';
// import 'package:yuyou_trucks/utils/event_bus.dart';
// import 'package:yuyou_trucks/utils/event_bus_const_key.dart';
final _aliyunPush = AliyunPush();

class IndexPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int currentIndex = 0;
  // final JPushFlutterInterface jpush = JPush.newJPush();
  late StreamSubscription<TabbarDidChangeBus> _tabbarDidChangeStream;
  //final pages = ;
  final pages = [const HomePage(), const DealPage(), const MinePage()];
  DateTime? _lastClickTime;
  final List<BottomNavigationBarItem> bottomNavItems = [
    BottomBarItem("tab_home", "自选"),
    BottomBarItem("tab_deal", "交易"),
    BottomBarItem("tab_mine", "我的"),
  ];

  @override
  void initState() {
    super.initState();
    print("HHHHHH--进入初始化index页面,初始化推送方法");
    // initJPushMethod();

    UmengCommonSdk.initCommon(
      '68f5d3808560e34872cef253',
      '68f5d3808560e34872cef253',
      'Umeng',
    );
    UmengCommonSdk.setPageCollectionModeAuto();
    initAliyunPush();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // 在当前帧绘制完成后执行的操作
      // 例如，执行一些需要等到UI渲染完成后才能进行的操作

      setState(() {
        ZzScreen().setContent(context);
      });
      // FloatingButtonOverlayManager().showFloatingButtonOverlay(context);
    });

    _tabbarDidChangeStream = zzEventBus.on<TabbarDidChangeBus>().listen((
      event,
    ) {
      setState(() {
        currentIndex = event.index;
      });
    });
  }

  Future<void> initAliyunPush() async {
    String appKey;
    String appSecret;
    // 配置App Key和App Secret（请在 https://emas.console.aliyun.com 获取）
    if (Platform.isIOS) {
      appKey = "填写自己iOS项目的appKey";
      appSecret = "填写自己iOS项目的appSecret";
    } else {
      appKey = "335594779";
      appSecret = "b19e310bc10d4311b88b3ed16d234986";
    }
    debugPrint("初始化推送0");
    _aliyunPush.initPush(appKey: appKey, appSecret: appSecret).then((
      initResult,
    ) {
      debugPrint("初始化推送1");
      var code = initResult['code'];
      debugPrint("初始化推送2$initResult");
      if (code == kAliyunPushSuccessCode) {
        debugPrint("初始化推送成功");
      } else {
        String errorMsg = initResult['errorMsg'];
        debugPrint('初始化推送失败, errorMsg: $errorMsg}');
      }
    });
    //延迟1s执行
    Future.delayed(Duration(seconds: 2)).then((value) {
      _initBasePush();
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  _initBasePush() {
    _aliyunPush.getDeviceId().then((deviceId) {
      // BaseSpStorage.getInstance().setaliyunPushId(deviceId);
      print("aliyun推送获取 设备 id : $deviceId");
      if (deviceId.isNotEmpty) {
        BaseSpStorage.getInstance().setdeviceId(deviceId);
      } else {
        if (BaseSpStorage.getInstance().deviceId.isEmpty) {
          BaseSpStorage.getInstance().setdeviceId("repet666${Uuid().v6()}");
        }
      }
    });
    if (Platform.isAndroid) {
      _aliyunPush.initAndroidThirdPush().then((initResult) {
        var code = initResult['code'];
        if (code == kAliyunPushSuccessCode) {
          debugPrint('初始化阿里云Android厂商通道成功');
        } else {
          debugPrint('初始化阿里云Android厂商通道失败${initResult["errorMsg"]}');
        }
      });
      // _aliyunPush.clearNotifications().then((result) {
      //   var code = result['code'];
      //   if (code == kAliyunPushSuccessCode) {
      //     debugPrint('清空阿里云Android成功');
      //   } else {
      //     debugPrint('清空阿里云Android失败${result["errorMsg"]}');
      //   }
      // });
      _aliyunPush
          .createAndroidChannel('defaultChannel', '默认通道', 3, 'defaultChannel')
          .then((createResult) {
            var code = createResult['code'];
            if (code == kAliyunPushSuccessCode) {
              debugPrint('创建默认通道成功');
            } else {
              var errorCode = createResult['code'];
              var errorMsg = createResult['errorMsg'];
              debugPrint('创建默认通道失败, errorCode: $errorCode errorMsg:$errorMsg');
            }
          });
    }
  }

  // initJPushMethod() {
  //   jpush.addEventHandler(
  //     // 接收通知回调方法。
  //     onReceiveNotification: (Map<String, dynamic> message) async {
  //       // pushMethod(message);
  //     },
  //     // 点击通知回调方法。
  //     onOpenNotification: (Map<String, dynamic> message) async {},
  //     // 接收自定义消息回调方法。
  //     onReceiveMessage: (Map<String, dynamic> message) async {
  //       pushMethod(message);
  //     },
  //   );

  //   jpush.setUnShowAtTheForeground(unShow: true); //app在前台也要展示消息
  //   jpush.setup(
  //     appKey: "802fb04d2fc2d3e768b71c7c",
  //     channel: "theChannel",
  //     production: true, //生产模式下使用true
  //     debug: true, // 设置是否打印 debug 日志
  //   );
  //   jpush.setWakeEnable(enable: true);
  //   jpush.applyPushAuthority(
  //     const NotificationSettingsIOS(sound: true, alert: true, badge: true),
  //   );

  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   jpush.getRegistrationID().then((rid) {
  //     print("极光推送获取 registration id : $rid");
  //     BaseSpStorage.getInstance().setjpushId(rid);
  //   });
  //   //清楚小红点
  //   jpush.setBadge(0);
  //   // 延时 3 秒后触发本地通知。

  //   // var fireDate = DateTime.fromMillisecondsSinceEpoch(
  //   //     DateTime.now().millisecondsSinceEpoch + 3000);
  //   // var localNotification = LocalNotification(
  //   //     id: 234,
  //   //     title: 'notification title',
  //   //     buildId: 1,
  //   //     content: 'notification content',
  //   //     fireTime: fireDate,
  //   //     subtitle: 'notification subtitle', // 该参数只有在 iOS 有效
  //   //     badge: 5, // 该参数只有在 iOS 有效

  //   //     );
  //   // jpush.sendLocalNotification(localNotification).then((res) {});
  // }

  // //push

  // pushMethod(Map<String, dynamic> message) {
  //   print("接收通知回调方法$message");

  //   zzEventBus.fire(OrderUpDataBus());
  //   BaseSpStorage.getInstance().updateUserInfo();
  //   String alert = "智金罗盘";
  //   String alert3 = message["alert"] ?? "";
  //   String alert1 = message["title"] ?? "";
  //   String alert2 = message["message"] ?? "";

  //   if ($notempty(alert1)) {
  //     alert = alert1;
  //   }
  //   if ($notempty(alert2)) {
  //     alert = alert2;
  //   }
  //   if ($notempty(alert3)) {
  //     alert = alert3;
  //   }

  //   Get.snackbar(
  //     "",
  //     "",
  //     colorText: ZzColor.color_333333, //颜色
  //     titleText: Text(alert, style: ZzFonts.fontBold333(16)),
  //     messageText: Text(alert, style: ZzFonts.fontBold666(12)),
  //     icon: Image.asset("assets/login/login_logo.png", width: 50, height: 50),
  //     padding: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
  //     backgroundColor: ZzColor.whiteColor.withOpacity(0.7),
  //     margin: const EdgeInsets.symmetric(horizontal: 20),
  //     isDismissible: true,
  //   );
  // }

  @override
  void dispose() {
    _tabbarDidChangeStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 预加载图片资源
    // precacheImage(const AssetImage('assets/home/ranking_top_bg.png'), context);
    // precacheImage(const AssetImage('assets/home/share_bg.png'), context);
    // precacheImage(const AssetImage('assets/mine/balance_top_bg.png'), context);
    // precacheImage(const AssetImage('assets/home/share.center.png'), context);

    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 214, 212, 212).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3), // 设置投影的偏移量
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: bottomNavItems,
          currentIndex: currentIndex,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 1,
          elevation: 10.0,
          backgroundColor: Colors.white,
          unselectedItemColor: const Color.fromRGBO(177, 177, 180, 1),
          selectedItemColor: ZzColor.mainAppColor,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            // EventBus().sendBroadcast(
            //     EventBusKey.tabbarDidChange, bottomNavItems[index].label);
            _changePage(index);
          },
        ),
      ),
      // ignore: deprecated_member_use
      body: WillPopScope(
        child: IndexedStack(index: currentIndex, children: pages),
        //onPopInvoked: (bool asd) {},//void Function(bool)? onPopInvoked
        onWillPop: () async {
          if (_lastClickTime == null ||
              DateTime.now().difference(_lastClickTime!) >
                  const Duration(seconds: 2)) {
            //两次点击间隔超过1秒则重新计时
            _lastClickTime = DateTime.now();
            //待完成
            ZzLoading.showMessage("再次操作退出应用");

            return false;
          }
          return true;
        },
      ), //这b玩意不能自己报错页面状态,需要用IndexedStack
    );
  }

  /*切换页面*/
  void _changePage(int index) {
    /*如果点击的导航项不是当前项  切换 */
    if (index != currentIndex) {
      zzEventBus.fire(TabbarOnChangeBus(index));
      // if (index == 1 && $empty(BaseSpStorage.getInstance().userToken)) {
      //   safePushToPage(context, "login_page");
      //   return;
      // }
      // if (index == 1) {
      //   zzEventBus.fire(OrderUpDataBus());
      // }
      BaseSpStorage.getInstance().updateUserInfo();

      setState(() {
        currentIndex = index;
      });
    }
  }
}

//解决第一次选中tab闪烁问题
class BottomBarItem extends BottomNavigationBarItem {
  BottomBarItem(String icon, String title)
    : super(
        //未选中图片
        icon: Column(
          children: [
            Image.asset(
              "assets/tabicon/$icon.png",
              width: title.isNotEmpty ? 24 : 40,
              excludeFromSemantics: true, //去除图片语义
              gaplessPlayback: true, //重新加载图片的过程中，原图片的展示是否保留
            ),
            title.isNotEmpty
                ? Text(title, style: ZzFonts.fontMedium111(10))
                : Container(),
          ],
        ),

        //选中图片
        activeIcon: Column(
          children: [
            Image.asset(
              "assets/tabicon/${icon}_select.png",
              width: title.isNotEmpty ? 24 : 40,
              excludeFromSemantics: true, //去除图片语义
              gaplessPlayback: true, //重新加载图片的过程中，原图片的展示是否保留
            ),
            title.isNotEmpty
                ? Text(title, style: ZzFonts.fontMediumMain(10))
                : Container(),
          ],
        ),
        label: "",
      );
}
