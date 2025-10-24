import 'dart:io';

import 'package:animations/animations.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/home/page/stock_detail_page.dart';
import 'package:zhijin_compass/screens/roots/base_webview_page.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/screens/search/model/hot_search_model.dart';
import 'package:zhijin_compass/screens/search/model/new_stock_model.dart';
import 'package:zhijin_compass/screens/search/model/search_model.dart';
import 'package:zhijin_compass/screens/search/model/stock_group_model.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'package:zhijin_compass/ztool/ztool_color.dart';
import 'package:zhijin_compass/ztool/ztool_fonts.dart';
import 'package:zhijin_compass/ztool/ztool_stock.dart';

class StockSearchPage extends StatefulWidget {
  const StockSearchPage({super.key});

  @override
  State<StockSearchPage> createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage>
    with LifecycleAware, LifecycleMixin {
  final TextEditingController _editingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<NewStockModel> _searchResult = [];
  List<HotSearchModel> _hotSearchList = [];
  List<NewStockModel> _collectStockList = [];
  bool _isLogin = true;
  bool _isDoneBuild = false;
  @override
  void onLifecycleEvent(LifecycleEvent event) {
    debugPrint("生命周期事件: $event");
    if (event == LifecycleEvent.active) {
      setState(() {
        _getCollectStockListUrl();
        _isLogin = $notempty(BaseSpStorage.getInstance().userToken)
            ? true
            : false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _editingController.addListener(() {
      _searchListener();
    });
    _scrollController.addListener(() {
      FocusScope.of(context).requestFocus(FocusNode());
    });
    _isLogin = $notempty(BaseSpStorage.getInstance().userToken) ? true : false;

    _getHotSearchListUrl();
    _getCollectStockListUrl();
    _getIsDoneBuildUrl();
  }

  _getHotSearchListUrl() {
    HttpUtil.getInstance().get(
      "/stock/hotSearch",
      successCallback: (data) {
        setState(() {
          _hotSearchList = List<HotSearchModel>.from(
            data.map((it) => HotSearchModel.fromJson(it)),
          );
        });
      },
      errorCallback: (errorCode, errorMsg) {},
    );
  }

  _getCollectStockListUrl() {
    if ($empty(BaseSpStorage.getInstance().userToken)) {
      setState(() {
        _collectStockList = BaseSpStorage.getInstance().localStockModels;
        debugPrint(
          "本地股票列表: ${_collectStockList.map((e) => e.symbol).join(',')}",
        );
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

  _addCollectStockUrl(NewStockModel params) {
    if ($empty(BaseSpStorage.getInstance().userToken)) {
      var list = [params, ...BaseSpStorage.getInstance().localStockModels];
      debugPrint("本地股票列表增加前: ${list.map((e) => e.symbol).join(',')}");

      BaseSpStorage.getInstance().setLocalStockModels(list);
      debugPrint("本地股票列表增加后: ${BaseSpStorage.getInstance().localStockList}");
      ZzLoading.showMessage("添加成功");
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
      "/portfolio/addStocks",
      data: {"symbol": symbol},
      successCallback: (data) {
        ZzLoading.showMessage("添加成功!");
        _getCollectStockListUrl();
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage("添加收藏股票失败: $errorMsg");
      },
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

  // 处理收藏股票数据
  _handleCollectStockData(List<dynamic> stocks) {
    setState(() {
      // 更新收藏股票列表状态
      _collectStockList = stocks.map((e) => NewStockModel.fromJson(e)).toList();
    });
  }

  _searchListener() async {
    String search = _editingController.text;
    getSearchResult(search);
  }

  @override
  void dispose() {
    _editingController.removeListener(_searchListener);
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(38),
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Container(
            margin: EdgeInsets.only(top: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () => safeGoback(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/icons/nav_back.png",
                          width: 18,
                          height: 18,
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffF2F2F2),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                    height: 40,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 12, left: 10, right: 10),
                      height: 40,

                      child: Row(
                        children: <Widget>[
                          Padding(padding: const EdgeInsets.only(left: 4)),
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              keyboardAppearance: Brightness.light,
                              cursorColor: ZzColor.mainAppColor,
                              controller: _editingController,
                              autocorrect: false,
                              cursorWidth: 2.0,

                              showCursor: true,
                              textInputAction: TextInputAction.search,
                              style: TextStyle(
                                color: ZzColor.color_333333,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(18), //限制长度
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9\u4e00-\u9fa5]'),
                                ), //只允许中文、字母和数字
                              ],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '输入股票代码/全拼/首字母',

                                //alignLabelWithHint: true,
                                hintStyle: TextStyle(
                                  color: Color(0xffA8A8A8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  textBaseline: TextBaseline.alphabetic,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15),
                  child: GestureDetector(
                    onTap: () {
                      if ($notempty(_editingController.text)) {
                        setState(() {
                          _editingController.text = '';
                          _searchResult = [];
                        });
                      } else {
                        safeGoback(context);
                      }
                    },
                    child: Text('取消', style: ZzFonts.fontNormal333(13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Visibility(
              visible:
                  _editingController.text.isNotEmpty && _searchResult.isEmpty,
              child: Container(
                padding: EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Image.asset('assets/images/search_none.png', height: 120),
                    SizedBox(height: 20),
                    Text("暂无数据", style: ZzFonts.fontNormal666(13)),
                  ],
                ),
              ),
            ),
            Visibility(
              visible:
                  _searchResult.isEmpty &&
                  $notempty(_hotSearchList) &&
                  _editingController.text.isEmpty,
              child: Container(
                //渐变色 一点点阴影
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffFFF0F1), ZzColor.whiteColor],
                  ),
                  //阴影
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      offset: Offset(0, -2),
                      blurRadius: 10,
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/icons/fire.png", height: 18),
                        SizedBox(width: 5),
                        Text("热门搜索", style: ZzFonts.fontMedium333(16)),
                      ],
                    ),
                    SizedBox(height: 8),
                    //写一个热门搜索的标签
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,

                        crossAxisAlignment: WrapCrossAlignment.start,
                        runAlignment: WrapAlignment.start,
                        children: _hotSearchList.map((item) {
                          return InkWell(
                            onTap: () {
                              if (_isDoneBuild) {
                                constPushToPage(
                                  context,
                                  StockDetailPage(
                                    model: NewStockModel.fromJson(
                                      item.toJson(),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xfff8f8f8),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                              child: Text(
                                "${ZZStockFormat().getSplitStockModel(item.symbol ?? '').prefix ?? ''} ${item.name}",
                                style: ZzFonts.fontNormal333(13),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 15),
                controller: _scrollController,
                itemCount: _searchResult.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      if (_isDoneBuild) {
                        constPushToPage(
                          context,
                          StockDetailPage(model: _searchResult[index]),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _searchResult[index].name ?? '',
                                    style: ZzFonts.fontMedium333(14),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "${ZZStockFormat().getSplitStockModel(_searchResult[index].symbol ?? '').prefix ?? ''} ${ZZStockFormat().getSplitStockModel(_searchResult[index].symbol ?? '').code ?? ''}",
                                    style: ZzFonts.fontNormal999(14),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  if (_collectStockList.any(
                                    (element) =>
                                        element.symbol ==
                                        _searchResult[index].symbol,
                                  )) {
                                    _removeCollectStockUrl(
                                      _searchResult[index],
                                    );
                                  } else {
                                    _addCollectStockUrl(_searchResult[index]);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    left: 30,
                                    right: 10,
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: Image.asset(
                                    _collectStockList.any(
                                          (element) =>
                                              element.symbol ==
                                              _searchResult[index].symbol,
                                        )
                                        ? 'assets/icons/collect_yes.png'
                                        : 'assets/icons/collect_no.png',
                                    height: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(color: ZzColor.lineColor, height: 1),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Visibility(
              visible: !_isLogin,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                decoration: BoxDecoration(
                  //渐变色
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffFFF3DD),
                      Color.fromARGB(255, 254, 244, 226),
                    ],
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
                        Image.asset('assets/images/home_plane.png', height: 25),
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
    );
  }

  //股票搜索
  getSearchResult(String searchkey) async {
    if ($empty(searchkey)) {
      setState(() {
        setState(() {
          _searchResult = [];
        });
      });
    }
    await HttpUtil.getInstance().get(
      "/stock/search",
      queryParameters: {"key": searchkey, "num": 999},
      successCallback: (data) {
        // ZzLoading.showMessage("移除成功!");
        // _getCollectStockListUrl();
        debugPrint("搜索结果---data: $data");
        List clist = data ?? [];
        List<SearchModel> list = clist
            .map((e) => SearchModel.fromJson(e))
            .toList();
        debugPrint("搜索结果---list: $list");

        List<NewStockModel> searchResultList = list
            .map(
              (item) => NewStockModel(
                symbol: item.standardCode ?? "",
                name: item.nameExtra ?? "",
                securityType: "A",
              ),
            )
            .toList();
        debugPrint("搜索结果---searchResultList: $searchResultList");
        setState(() {
          _searchResult = searchResultList;
        });
      },
      errorCallback: (errorCode, errorMsg) {
        setState(() {
          _searchResult = [];
        });
        //  ZzLoading.showMessage("添加收藏股票失败: $errorMsg");
      },
    );

    // String type = "11";
    // String urlStr =
    //     "https://suggest3.sinajs.cn/suggest/type=$type&name=suggestvalue&key=$searchkey&num=99&dpc=1";
    // var httpClient = HttpClient();
    // HttpClientRequest request = await httpClient.getUrl(Uri.parse(urlStr));
    // HttpClientResponse response = await request.close();
    // httpClient.close();
    // if (response.statusCode == 200) {
    //   var responseBody = await response.transform(gbk.decoder).join();
    //   print(responseBody);
    //   //处理返回结果
    //   if (responseBody.isEmpty) {
    //     return [];
    //   }

    //   List<String> suggestvalues = responseBody.split(";");
    //   if (suggestvalues.length == 2 &&
    //       suggestvalues[0] == "var suggestvalue=\"\"") {
    //     return [];
    //   }

    //   List<NewStockModel> searchResultList = [];
    //   for (int i = 0; i < suggestvalues.length; i++) {
    //     String stockString = suggestvalues[i];
    //     if (stockString.isEmpty) {
    //       continue;
    //     }

    //     List stockInfoArray = stockString.split(",");
    //     NewStockModel newStockModel = NewStockModel();

    //     for (int s = 0; s < stockInfoArray.length; s++) {
    //       String contentString = stockInfoArray[s];
    //       if (s == 1) {
    //         newStockModel.market = ZZStockFormat().getMarketWithResultType(
    //           contentString,
    //         );
    //         if (contentString == "11") {
    //           newStockModel.securityType = "A";
    //         } else if (contentString == "22") {
    //           newStockModel.securityType = "E";
    //         } else if (contentString == "120" ||
    //             contentString == "81" ||
    //             contentString == "82") {
    //           newStockModel.securityType = "Z";
    //         }
    //       }
    //       if (newStockModel.market == "us") {
    //         if (s == 2) {
    //           newStockModel.symbol = contentString;
    //           newStockModel.symbolType = ZZStockFormat()
    //               .getSymbolTypeWithMarketAndSymbol(
    //                 newStockModel.market ?? '',
    //                 newStockModel.symbol ?? '',
    //               );
    //         }
    //       } else {
    //         if (s == 3) {
    //           newStockModel.symbol = contentString;
    //           newStockModel.symbolType = ZZStockFormat()
    //               .getSymbolTypeWithMarketAndSymbol(
    //                 newStockModel.market ?? '',
    //                 newStockModel.symbol ?? '',
    //               );
    //         }
    //       }
    //       if (s == 6) {
    //         newStockModel.name = contentString;
    //       }
    //     }
    //     searchResultList.add(newStockModel);
    //   }

    //   searchResultList = handleBlackListStock(searchResultList);

    //   return searchResultList;
    // }
  }

  List<NewStockModel> handleBlackListStock(List<NewStockModel> stockList) {
    List<String> stockBlackList = [
      "000816",
      "000929",
      "000930",
      "001893",
      "001981",
      "001982",
      "002318",
      "002469",
      "002852",
      "003022",
      "003252",
      "003253",
      "003034",
      "003506",
      "003507",
      "003816",
      "004097",
      "004372",
      "004373",
      "004749",
      "004869",
      "005107",
      "005153",
      "159006",
      "159004",
      "159002",
      "007522",
    ];

    List<NewStockModel> new_stockList = [];

    for (final stock in stockList) {
      bool contain = false;
      for (final blackStock in stockBlackList) {
        if ((stock.symbol ?? '').contains(blackStock)) {
          contain = true;
          break;
        }
      }
      if (!contain) {
        new_stockList.add(stock);
      }
    }

    return new_stockList;
  }
}
