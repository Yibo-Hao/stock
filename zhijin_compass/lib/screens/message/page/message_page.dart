import 'package:aliyun_push/aliyun_push.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:jpush_flutter/jpush_flutter.dart';
// import 'package:jpush_flutter/jpush_interface.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/tools/ZzPermissionTool.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'package:zhijin_compass/ztool/ztool_appbar.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with LifecycleAware, LifecycleMixin {
  bool _isPushAble = false;
  var _groups = {};
  List _dataArr = [];
  // final JPushFlutterInterface jpush = JPush.newJPush();
  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.active) {
      _getPushStatus();
      _getMessageGroup();
    }
  }

  _getPushStatus() async {
    AliyunPush().isAndroidNotificationEnabled().then((value) {
      setState(() {
        if (mounted) {
          setState(() {
            _isPushAble = value;
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // jpush.isNotificationEnabled().then((value) => {_initPushStatus(value)});
    //  _getMessageGroup();
  }

  _getMessageGroup() {
    _dataArr = [];
    HttpUtil.getInstance().get(
      "/message/getMessageType",
      successCallback: (data) {
        setState(() {
          _groups = data;
          _groups.forEach((key, value) {
            _dataArr.add({"title": value, "type": key});
            _getMessageCount(key);
          });
        });
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage(errorMsg);
      },
    );
  }

  _getMessageCount(type) {
    HttpUtil.getInstance().get(
      "/message/getUnReadMessageNum",
      queryParameters: {"type": type},
      successCallback: (data) {
        setState(() {
          for (var item in _dataArr) {
            if (item["type"] == type) {
              item["count"] = data;
              break;
            }
          }
        });
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage(errorMsg);
      },
    );

    HttpUtil.getInstance().get(
      "/message/getMessage",
      queryParameters: {"pageNum": 0, "pageSize": 1, "type": type},
      successCallback: (data) {
        List list = data["data"] ?? [];
        if (list.isNotEmpty) {
          setState(() {
            for (var item in _dataArr) {
              if (item["type"] == type) {
                item["subtitle"] = list[0]["content"] ?? '';
                break;
              }
            }
          });
        }
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage(errorMsg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZzColor.pageBackGround,
      appBar: ZzAppBar(title: "消息中心"),
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
                      InkWell(
                        onTap: () => showPushPermissDialog(
                          context,
                          mounted,
                          onGranted: () {
                            _getPushStatus();
                          },
                        ),
                        child: Container(
                          decoration: ZzDecoration.onlyradius(
                            100,
                            ZzColor.mainAppColor,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          child: Center(
                            child: Text(
                              '去开启',
                              style: ZzFonts.fontNormalWhite(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ..._dataArr.map(
                (item) => InkWell(
                  onTap: () {
                    safePushToPage(
                      context,
                      "message_detail_page",
                      arguments: {
                        "params": {
                          "title": item["title"],
                          "type": item["type"],
                        },
                      },
                    );
                  },
                  child: Container(
                    color: ZzColor.whiteColor,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/msg_iocn.png',
                                height: 40,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["title"],
                                      style: ZzFonts.fontMedium111(14),
                                    ),
                                    Text(
                                      item["subtitle"] ?? "暂无消息",
                                      style: ZzFonts.fontNormal333(12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Badge(
                              textColor: ZzColor.whiteColor,
                              label: (item["count"] ?? 0) > 1
                                  ? Text(
                                      (item["count"] ?? 0) > 99
                                          ? "99+"
                                          : "${(item["count"] ?? 0)}",
                                    )
                                  : null,
                              offset: Offset(-1, 1),
                              isLabelVisible: (item["count"] ?? 0) > 0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
