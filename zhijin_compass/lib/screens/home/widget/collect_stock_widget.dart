import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/home/page/stock_detail_page.dart';
import 'package:zhijin_compass/screens/roots/base_webview_page.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/screens/search/model/new_stock_model.dart';
import 'package:zhijin_compass/tools/ZzCustomDialog.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

class CollectStockWidget extends StatefulWidget {
  const CollectStockWidget({
    super.key,
    required this.collectStockList,
    this.onLongPress,
  });
  final List<NewStockModel> collectStockList;
  final Function(NewStockModel)? onLongPress;

  @override
  State<CollectStockWidget> createState() => _CollectStockWidgetState();
}

// 添加排序状态枚举
enum SortStatus {
  none, // 默认状态
  asc, // 升序
  desc, // 降序
}

class _CollectStockWidgetState extends State<CollectStockWidget>
    with LifecycleAware, LifecycleMixin {
  WebSocketChannel? _channel;
  StreamSubscription? subscription;
  Map<String, Map<String, dynamic>> _stockData = {};

  SortStatus _sortStatus = SortStatus.none;
  List<NewStockModel> _sortedStockList = [];

  final String wssBaseUrl = "wss://hq.sinajs.cn/wskt?list=";
  String wssFullUrl = "";
  bool _isDoneBuild = false;

  @override
  void initState() {
    super.initState();
    _getIsDoneBuildUrl();
  }

  initData() {
    final symbols = widget.collectStockList.map((e) => e.symbol).toList();
    if (symbols.isEmpty) {
      // 如果列表为空，确保关闭现有连接
      if (_channel != null) {
        _channel!.sink.close();
      }
      return;
    }

    //组装socket请求参数
    String socketParams = "";

    if (widget.collectStockList.isNotEmpty) {
      socketParams = symbols.join(',');
      // for (var item in widget.collectStockList) {
      //   socketParams += "${item.symbol},";
      // }
    }

    //
    if (wssFullUrl != wssBaseUrl + socketParams) {
      //当股票参数变化时再重新初始化

      wssFullUrl = wssBaseUrl + socketParams;
      //启动socket
      initSocket();
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

  //初始化socket
  initSocket() {
    if (wssFullUrl == wssBaseUrl) {
      return;
    }

    //如果有连接 ，先取消
    if (subscription != null) {
      subscription?.cancel();
    }
    if (_channel != null) {
      _channel?.sink.close();
    }
    debugPrint("wssFullUrl1=$wssFullUrl");
    _channel = IOWebSocketChannel.connect(
      wssFullUrl,
      pingInterval: Duration(seconds: 30),
      headers: {
        'Origin': 'https://izq.sina.com.cn',
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36',
      },
    );
    subscription = _channel?.stream.listen(
      (message) => onData(message),
      onError: onError,
      onDone: onDone,
    );
  }

  onDone() {
    debugPrint("Socket is closed");
    debugPrint("wssFullUrl2=$wssFullUrl");
    _channel = IOWebSocketChannel.connect(
      wssFullUrl,
      pingInterval: Duration(seconds: 30),
      headers: {
        'Origin': 'https://izq.sina.com.cn',
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36',
      },
    );
  }

  onError(err) {
    debugPrint(err.runtimeType.toString());
    WebSocketChannelException ex = err;
    debugPrint(ex.message);
  }

  onData(String event) {
    // debugPrint("链接成功监听数据------$event");
    final stockList = event.split('\n')..removeLast();

    // 更新股票数据后应用当前排序
    setState(() {
      _applySort();
    });

    for (final subStr in stockList) {
      final subArr = subStr.split('=');
      if (subArr.length < 2) continue;

      final symbolName = subArr[0];
      final symbolDes = subArr[1];
      final symbolArr = symbolDes.split(',');

      final name = symbolArr[0];
      String price, diff, chg, amount;

      if (double.parse(symbolArr[3]) == 0 && double.parse(symbolArr[8]) == 0) {
        price = double.parse(symbolArr[2]).toStringAsFixed(2);
        diff = (double.parse(symbolArr[2]) - double.parse(symbolArr[2]))
            .toStringAsFixed(2);
      } else {
        price = double.parse(symbolArr[3]).toStringAsFixed(2);
        diff = (double.parse(symbolArr[3]) - double.parse(symbolArr[2]))
            .toStringAsFixed(2);
      }

      chg = (100 * double.parse(diff) / double.parse(symbolArr[2]))
          .toStringAsFixed(2);
      amount = ZzString.formatMoney(double.parse(symbolArr[9]));

      setState(() {
        _stockData[symbolName] = {
          "name": name,
          "price": price,
          "diff": diff,
          "chg": chg,
          "amount": amount,
          "symbol": symbolName,
        };
      });
    }
  }

  @override
  void dispose() {
    _objDispose();
    super.dispose();
    //print("Socket dispose关闭");
  }

  //销毁对象
  _objDispose() {
    if (subscription != null) {
      subscription?.cancel();
      subscription = null;
    }
    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
    }
  }

  // 应用排序方法
  void _applySort() {
    _sortedStockList = List.from(widget.collectStockList);

    if (_sortStatus != SortStatus.none) {
      _sortedStockList.sort((a, b) {
        double aChg = double.tryParse(_stockData[a.symbol]?['chg'] ?? '0') ?? 0;
        double bChg = double.tryParse(_stockData[b.symbol]?['chg'] ?? '0') ?? 0;

        return _sortStatus == SortStatus.asc
            ? aChg.compareTo(bChg)
            : bChg.compareTo(aChg);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initData();
    return CustomScrollView(
      slivers: <Widget>[
        SliverStickyHeader.builder(
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: Center(
                      child: Text(
                        "股票名称",
                        style: ZzFonts.fontByBase(
                          14,
                          Color(0xff7a7a7a),
                          FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Center(
                      child: Text(
                        "最新价",
                        style: ZzFonts.fontByBase(
                          14,
                          Color(0xff7a7a7a),
                          FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          // 循环切换排序状态
                          _sortStatus =
                              SortStatus.values[(_sortStatus.index + 1) %
                                  SortStatus.values.length];
                          _applySort();
                        });
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "涨跌幅",
                              style: ZzFonts.fontByBase(
                                14,
                                Color(0xff7a7a7a),
                                FontWeight.normal,
                              ),
                            ),
                            _sortStatus != SortStatus.none
                                ? Image.asset(
                                    _sortStatus == SortStatus.asc
                                        ? 'assets/icons/sort_up.png'
                                        : 'assets/icons/sort_down.png',
                                    height: 14,
                                  )
                                : Image.asset(
                                    'assets/icons/sort_up.png',
                                    color: Color(0xffCDCDCD),

                                    height: 14,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Center(
                      child: Text(
                        "金额",
                        style: ZzFonts.fontByBase(
                          14,
                          Color(0xff7a7a7a),
                          FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          sliver: SliverToBoxAdapter(
            child: Container(
              //长按弹出菜单,弹出位置跟随长按位置
              color: ZzColor.whiteColor,
              child: Column(
                children: _sortedStockList.map((stock) {
                  final data =
                      _stockData[stock.symbol] ??
                      {
                        "name": stock.name,
                        "symbol": stock.symbol,
                        "price": "0.00",
                        "diff": "0.00",
                        "chg": "0.00",
                        "amount": "0.00",
                      };
                  stock.name ??= data["name"];
                  stock.symbol ??= data["symbol"];
                  stock.price ??= data["price"];
                  stock.diff ??= data["diff"];
                  stock.chg ??= data["chg"];
                  return InkWell(
                    onTap: () {
                      if (_isDoneBuild) {
                        constPushToPage(context, StockDetailPage(model: stock));
                      }
                    },
                    onLongPress: () {
                      if (widget.onLongPress != null) {
                        widget.onLongPress!(stock);
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 8,
                                child: Column(
                                  children: [
                                    Text(
                                      data["name"] ?? '',
                                      style: ZzFonts.fontNormal333(15),
                                    ),
                                    SizedBox(height: 1),
                                    Text(
                                      data["symbol"] ?? '',
                                      style: ZzFonts.fontNormal999(13),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Center(
                                  child: Text(
                                    data["price"] ?? '0.00',
                                    style: ZzFonts.fontByBase(
                                      15,
                                      ZZStockFormat.getColorByDiff(
                                        data["diff"],
                                      ),
                                      FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Center(
                                  child: Text(
                                    '${double.parse(data["chg"] ?? '0') > 0 ? '+' : ''}${data["chg"] ?? '0.00'}%',
                                    style: ZzFonts.fontByBase(
                                      15,
                                      ZZStockFormat.getColorByDiff(
                                        data["diff"],
                                      ),
                                      FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Center(
                                  child: Text(
                                    data["amount"] ?? '0.00',
                                    style: ZzFonts.fontMedium333(15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Divider(color: ZzColor.lineColor, height: 1),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.inactive) {
      _objDispose();
    } else if (event == LifecycleEvent.active) {
      if (wssFullUrl.length > wssBaseUrl.length) {
        //当有股票参数时才启动
        initSocket();
      }
    }
  }
}
