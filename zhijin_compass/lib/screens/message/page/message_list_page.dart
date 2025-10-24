import 'package:aliyun_push/aliyun_push.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:jpush_flutter/jpush_flutter.dart';
// import 'package:jpush_flutter/jpush_interface.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/message/model/message_model.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/tools/ZzCustomDialog.dart';
import 'package:zhijin_compass/tools/ZzPermissionTool.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'package:zhijin_compass/ztool/ztool_appbar.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({super.key, required this.params});
  final Map params;

  @override
  State<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage>
    with LifecycleAware, LifecycleMixin {
  bool _isPushAble = false;
  late RefreshController _refreshController;
  int _pageNum = 0;
  List<MessageModel> _dataArr = [];
  // 条目总数
  final int _count = 20;
  var _groups = {};
  // final JPushFlutterInterface jpush = JPush.newJPush();
  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.active) {
      _getPushStatus();
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
    _refreshController = RefreshController();
    // jpush.isNotificationEnabled().then((value) => {_initPushStatus(value)});
    _getMessageGroup();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 200), () {
      _pageNum = 0;
      _getMessageGroup();
    });
  }

  Future<void> _onLoad() async {
    await Future.delayed(const Duration(milliseconds: 200), () {
      _pageNum++;
      _getMessageGroup();
    });
  }

  _readMessage(MessageModel model, {bool isReadAll = false}) {
    ZzLoading.show();
    HttpUtil.getInstance().post(
      "/message/messageRead",
      data: {
        "readAll": isReadAll,
        "messageIds": [model.id], //读取的id
        "type": widget.params["type"],
      },
      successCallback: (data) {
        ZzLoading.dismiss();
        if (isReadAll == true) {
          _getMessageGroup();
        }
        setState(() {
          model.isRead = true;
        });
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage(errorMsg);
      },
    );
  }

  _getMessageGroup() {
    if ($empty(BaseSpStorage.getInstance().userToken)) {
      return;
    }
    ZzLoading.show();
    HttpUtil.getInstance().get(
      "/message/getMessage",
      queryParameters: {
        "pageNum": _pageNum,
        "pageSize": _count,
        "type": widget.params["type"],
      },
      successCallback: (data) {
        ZzLoading.dismiss();
        List clist = data["data"] ?? [];
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
        List<MessageModel> list = List<MessageModel>.from(
          clist.map((it) => MessageModel.fromJson(it)),
        );

        setState(() {
          if (_pageNum == 0) {
            _dataArr = list;
          } else {
            _dataArr.addAll(list);
          }
        });
        if (list.length < _count) {
          setState(() {
            _refreshController.loadNoData();
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
      appBar: ZzAppBar(
        title: widget.params["title"],
        rightIcon: Text("全部已读", style: ZzFonts.fontNormal666(14)),
        onRightTap: () {
          //
          ZzCustomDialog.show(
            context: context,
            image: Positioned(
              top: -75,
              left: 0,
              right: 0,
              child: Image.asset('assets/images/mine_clear.png', height: 150),
            ),
            content: '确定要全部已读?',
            leftButtonText: "取消",
            rightButtonText: "全部已读",
            rightButtonAction: () {
              _readMessage(MessageModel(id: null), isReadAll: true);
              safeGoback(context);
            },
          );
        },
      ),
      body: SafeArea(
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
                          ZzLoading.showMessage('text');
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
            Expanded(
              child: ZzRefresh(
                refreshController: _refreshController,
                onRefresh: () => _onRefresh(),
                onLoading: () => _onLoad(),
                child: CustomScrollView(
                  slivers: <Widget>[
                    ..._dataArr.map(
                      (item) => SliverToBoxAdapter(
                        child: InkWell(
                          onTap: () {
                            _readMessage(item);
                          },
                          child: Container(
                            color: ZzColor.whiteColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            margin: EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/msg_iocn.png',
                                      height: 40,
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: ZzScreen().screenWidth - 95,
                                          child: Text(
                                            item.content ?? '',
                                            style: ZzFonts.fontMedium111(14),
                                          ),
                                        ),
                                        Text(
                                          _formatTime(item.createTime),
                                          style: ZzFonts.fontNormal333(12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    // Text(
                                    //   "09:22",
                                    //   style: ZzFonts.fontNormal666(12),
                                    // ),
                                    (item.isRead == false)
                                        ? Container(
                                            height: 10,
                                            width: 10,

                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ],
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
      ),
    );
  }

  //写个方法,传入时间字符串2025-09-08T19:27:52.000+00:00,如果是今天返回 hh:mm:ss,不是今天返回yyyy-MM-dd hh:mm:ss
  String _formatTime(String? time) {
    if ($empty(time)) {
      return '';
    }
    DateTime dateTime = DateTime.parse(time!);

    if (dateTime.year == DateTime.now().year &&
        dateTime.month == DateTime.now().month &&
        dateTime.day == DateTime.now().day) {
      return DateFormat('HH:mm:ss').format(dateTime);
    } else {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    }
  }
}
