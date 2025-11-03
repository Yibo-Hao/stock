import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/home/widget/collect_stock_widget.dart';
import 'package:zhijin_compass/screens/roots/root_event_bus.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/screens/home/widget/stock_index_widget.dart';
import 'package:zhijin_compass/screens/search/model/new_stock_model.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/tools/ZzCustomDialog.dart';
import 'package:zhijin_compass/tools/ZzPermissionTool.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with LifecycleAware, LifecycleMixin {
  late RefreshController _refreshController;
  late ScrollController _scrollController;
  bool _isLogin = false;
  late StreamSubscription<TabbarOnChangeBus> updateDataStream;
  late StreamSubscription<LoginBus> loginStream;
  List<NewStockModel> _collectStockList = [];
  bool _isDoneBuild = false;
  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.active) {
      setState(() {
        _isLogin = BaseSpStorage.getInstance().userToken.isNotEmpty;
        _getCollectStockListUrl();
      });
    }
  }

  _getIsDoneBuildUrl() {
    HttpUtil.getInstance().get(
      "/user/isLastVersion",
      successCallback: (data) {
        ZzLoading.dismiss();
        setState(() {
          _isDoneBuild = data ?? false;
        });
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage(errorMsg);
      },
    );
  }
  // Future<void> _onRefresh() async {
  //   await Future.delayed(const Duration(milliseconds: 200), () {
  //     _getCollectStockListUrl();
  //   });
  // }

  // Future<void> _onLoad() async {
  //   _getCollectStockListUrl();
  // }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _scrollController = ScrollController();
    if ($notempty(BaseSpStorage.getInstance().userToken)) {
      _isLogin = true;
      // _getCollectStockListUrl();
    }
    updateDataStream = zzEventBus.on<TabbarOnChangeBus>().listen((event) {
      if (mounted && event.index == 0) {
        setState(() {
          _isLogin = BaseSpStorage.getInstance().userToken.isNotEmpty;
          _getCollectStockListUrl();
        });
      }
    });
    loginStream = zzEventBus.on<LoginBus>().listen((event) {
      setState(() {
        _isLogin = BaseSpStorage.getInstance().userToken.isNotEmpty;
      });
      _getCollectStockListUrl();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          showPushPermissDialog(context, mounted);
        }
      });
    });
  }

  _syncLocalStockToServe() {
    if ($empty(BaseSpStorage.getInstance().userToken)) {
      return;
    }
    final localStocks = BaseSpStorage.getInstance().localStockModels;
    if (localStocks.isNotEmpty) {
      //进行同步本地股票列表和服务器数据
      final symbols = localStocks.map((stock) => _getClassName(stock)).toList();
      debugPrint("本地股票列表拼参: ${symbols.join(',')}");
      HttpUtil.getInstance().post(
        "/portfolio/addStocks",
        data: {"symbol": symbols.join(',')},
        successCallback: (data) {
          BaseSpStorage.getInstance().cleanLocalStockList();
        },
        errorCallback: (errorCode, errorMsg) {
          ZzLoading.showMessage("$errorMsg");
          if (errorCode == '300001') {
            BaseSpStorage.getInstance().cleanLocalStockList();
          }
        },
      );
    } else {
      debugPrint("无本地股票无需同步");
    }
  }

  String _getClassName(NewStockModel params) {
    debugPrint("打印本地股票列表231: ${params.symbol}@cn@${params.securityType}");
    String symbol;
    if (params.securityType == 'E') {
      symbol = "${params.symbol}@cn@e";
    } else if (params.securityType == 'Z') {
      symbol = "${params.symbol}@cn@z";
    } else {
      symbol = "${params.symbol}@cn@s";
    }
    return symbol;
  }

  _getCollectStockListUrl() {
    _getIsDoneBuildUrl();
    if ($empty(BaseSpStorage.getInstance().userToken)) {
      setState(() {
        final localStocks = BaseSpStorage.getInstance().localStockModels;
        _handleCollectStockData(
          localStocks.map((e) => {"symbol": e.symbol}).toList(),
        );
        debugPrint("本地股票列表: ${localStocks.map((e) => e.symbol).join(',')}");
      });
      return;
    }

    HttpUtil.getInstance().get(
      "/portfolio/codeGroupOnlyStocks",
      successCallback: (data) {
        if (data != null && data is List) {
          // 处理收藏股票数据
          _handleCollectStockData(data);
        } else {
          ZzLoading.showMessage("获取收藏股票数据格式错误");
        }
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage("获取收藏股票失败: $errorMsg");
      },
    );
  }

  // 处理收藏股票数据
  _handleCollectStockData(List<dynamic> stocks) {
    _syncLocalStockToServe();
    final newList = stocks.map((e) => NewStockModel.fromJson(e)).toList();
    // 只有当数据确实变化时才更新
    if (newList.length != _collectStockList.length ||
        !newList.every(
          (newItem) => _collectStockList.any(
            (oldItem) => newItem.symbol == oldItem.symbol,
          ),
        )) {
      setState(() {
        _collectStockList = newList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ZzScreen().setContent(context);
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        backgroundColor: ZzColor.mainAppColor,
        // pinned: true,
        elevation: 0.01,
        primary: true,
        // floating: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: Text(
                '智金罗盘',
                style: TextStyle(color: ZzColor.whiteColor, fontSize: 16),
              ),
            ),

            Expanded(
              child: InkWell(
                onTap: () => safePushToPage(context, 'stock_search_page'),
                child: Container(
                  decoration: ZzDecoration.onlyradius(
                    100,
                    Color.fromARGB(81, 255, 218, 218),
                  ),
                  margin: const EdgeInsets.only(left: 25, right: 0),
                  height: 35,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/home_search.png',
                        width: 20,
                        height: 20,
                        color: Color(0xffFFDADA),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '输入股票代码/全拼/首字母',
                        style: TextStyle(
                          color: Color.fromARGB(175, 255, 218, 218),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        //设置背景视图,上面有个80高的色块
        decoration: const BoxDecoration(color: ZzColor.pageBackGround),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xffF1525B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      //---------------指数行情------------------
                      StockIndexWidget(
                        symbols: ["sh000001", "sz399001", "sz399006"],
                        isDoneBuild: _isDoneBuild,
                        onNewsTap: () => safePushToPage(context, 'news_page'),
                      ),
                      //--------------上面是指数
                      Expanded(
                        child: _isLogin || $notempty(_collectStockList)
                            ? Container(
                                key: ValueKey<List<NewStockModel>>(
                                  _collectStockList,
                                ), // 添加唯一key
                                margin: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 8,
                                  bottom: 8,
                                ),
                                padding: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  color: Colors.white,
                                ),
                                child: CollectStockWidget(
                                  collectStockList: _collectStockList,
                                  isDoneBuild: _isDoneBuild,
                                  onLongPress: (stock) {
                                    ZzCustomDialog.show(
                                      context: context,
                                      image: Positioned(
                                        top: -75,
                                        left: 0,
                                        right: 0,
                                        child: Image.asset(
                                          'assets/images/dialog_warnning.png',
                                          height: 150,
                                        ),
                                      ),
                                      content: "确定删除当前股票吗?",
                                      leftButtonText: "取消",
                                      rightButtonText: "删除",
                                      rightButtonAction: () {
                                        _removeCollectStockUrl(stock);
                                        safeGoback(context);
                                      },
                                    );
                                  },
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(top: 50),
                                child: Column(
                                  children: [
                                    Image(
                                      image: AssetImage(
                                        'assets/images/home_no_login.png',
                                      ),
                                      height: 200,
                                    ),
                                    Text(
                                      '账号还未登录',
                                      style: ZzFonts.fontNormal333(14),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        safePushToPage(context, 'login_page');
                                      },
                                      child: Container(
                                        width: 150,
                                        height: 40,
                                        margin: EdgeInsets.only(top: 20),
                                        decoration: ZzDecoration.onlyradius(
                                          100,
                                          ZzColor.mainAppColor,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '去登录/注册',
                                            style: ZzFonts.fontNormalWhite(14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Visibility(
                        visible: !(!_isLogin && $empty(_collectStockList)),
                        child: InkWell(
                          onTap: () =>
                              safePushToPage(context, 'stock_search_page'),
                          child: Container(
                            height: 35,
                            margin: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                              border: Border.all(
                                color: Color(0xffF1525B),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '添加股票',
                                style: TextStyle(
                                  color: Color(0xffF1525B),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !_isLogin && $notempty(_collectStockList),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          margin: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          decoration: BoxDecoration(
                            //渐变色
                            gradient: LinearGradient(
                              colors: [Color(0xffFFF3DD), Color(0xffFFFCF7)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/home_plane.png',
                                    height: 25,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "登录后同步自选股，数据不丢失",
                                    style: ZzFonts.fontNormal333(14),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  safePushToPage(context, 'login_page');
                                },
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
                                      '立即登录',
                                      style: ZzFonts.fontNormalWhite(12),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  _removeCollectStockUrl(NewStockModel params) {
    if ($empty(BaseSpStorage.getInstance().userToken)) {
      var list = [...BaseSpStorage.getInstance().localStockModels];
      list.removeWhere((element) => element.symbol == params.symbol);

      BaseSpStorage.getInstance().setLocalStockModels(list);
      ZzLoading.showMessage("移除成功");
      _getCollectStockListUrl();
      return;
    }
    ZzLoading.show();
    String symbol;
    if (params.securityType == 'E') {
      symbol = "${params.symbol}@cn@e";
    } else if (params.securityType == 'Z') {
      symbol = "${params.symbol}@cn@z";
    } else {
      symbol = "${params.symbol}@cn@s";
    }
    HttpUtil.getInstance().post(
      "/portfolio/removeStocks",
      data: {"symbol": symbol},
      successCallback: (data) {
        ZzLoading.showMessage("移除成功!");
        _getCollectStockListUrl();
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage("添加收藏股票失败: $errorMsg");
      },
    );
  }
}
