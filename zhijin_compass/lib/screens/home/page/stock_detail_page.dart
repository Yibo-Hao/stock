import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/screens/search/model/new_stock_model.dart';
import 'package:zhijin_compass/screens/search/page/stock_search_page.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'package:flutter/scheduler.dart';

class StockDetailPage extends StatefulWidget {
  const StockDetailPage({super.key, this.model});
  final NewStockModel? model;

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage>
    with SingleTickerProviderStateMixin {
  late final WebViewController controller;
  bool _isLoading = true;
  var _progress = 0;
  late AnimationController _animationController;
  List<NewStockModel> _collectStockList = [];
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

  // 处理收藏股票数据
  _handleCollectStockData(List<dynamic> stocks) {
    setState(() {
      // 更新收藏股票列表状态
      _collectStockList = stocks.map((e) => NewStockModel.fromJson(e)).toList();
    });
  }

  _addCollectStockUrl(NewStockModel params) {
    if ($empty(BaseSpStorage.getInstance().userToken)) {
      var list = [...BaseSpStorage.getInstance().localStockModels, params];
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

  _removeCollectStockUrl(NewStockModel? params) {
    if ($empty(BaseSpStorage.getInstance().userToken)) {
      var list = [...BaseSpStorage.getInstance().localStockModels];
      list.removeWhere((element) => element.symbol == params?.symbol);

      BaseSpStorage.getInstance().setLocalStockModels(list);
      ZzLoading.showMessage("移除成功");
      _getCollectStockListUrl();
      return;
    }
    ZzLoading.show();
    String symbol;
    if (params?.securityType == 'E') {
      symbol = "${params?.symbol}@cn@e";
    } else if (params?.securityType == 'Z') {
      symbol = "${params?.symbol}@cn@z";
    } else {
      symbol = "${params?.symbol}@cn@s";
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

  @override
  void initState() {
    super.initState();
    ZzLoading.show();
    _getCollectStockListUrl();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress;
            });
            if (progress > 95) {
              ZzLoading.dismiss();
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              _hasError = false;
            });
            ZzLoading.dismiss();
          },

          onHttpError: (error) {
            _showErrorPage();
          },
          onWebResourceError: (WebResourceError error) {
            _showErrorPage();
          },
          // onNavigationRequest: (NavigationRequest request) async {
          //   // 检查是否是返回操作
          //   if (await controller.canGoBack()) {
          //     final currentUrl = await controller.currentUrl();
          //     // 检查当前URL是否不包含/stock-details
          //     if (currentUrl != null &&
          //         !currentUrl.contains('/stock-details')) {
          //       // 不是目标页面，调用浏览器返回
          //       controller.goBack();
          //       return NavigationDecision.prevent;
          //     }
          //   }
          //   return NavigationDecision.navigate;
          // },
        ),
      );

    try {
      String url =
          "http://web-test.qcoral.tech/stock-details?symbol=${widget.model?.symbol}&add=null";
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      controller.loadRequest(Uri.parse(url));
    } catch (e) {
      ZzLoading.showMessage('加载网页失败: $e');
      _showErrorPage();
    }
  }

  bool _hasError = false;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _goBack() {
    if (mounted) {
      safeGoback(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZzAppBar(
        backColor: ZzColor.whiteColor,
        title: widget.model?.name ?? "详情",
        onLeftTap: () async {
          if (await controller.canGoBack()) {
            final currentUrl = await controller.currentUrl();
            // 检查当前URL是否不包含/stock-details
            if (currentUrl != null && !currentUrl.contains('/stock-details')) {
              // 不是目标页面，调用浏览器返回
              controller.goBack();
              return;
            }
          }
          _goBack();
        },
        rightIcon: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => StockSearchPage()),
                    (route) => route.isFirst,
                  );
                },
                child: Image.asset('assets/icons/search.png', height: 22),
              ),
              SizedBox(width: 15),
              InkWell(
                onTap: () {
                  if ((_collectStockList).any(
                    (element) => element.symbol == widget.model?.symbol,
                  )) {
                    _removeCollectStockUrl(widget.model);
                  } else {
                    _addCollectStockUrl(widget.model!);
                  }
                },
                child: Image.asset(
                  (_collectStockList).any(
                        (element) => element.symbol == widget.model?.symbol,
                      )
                      ? 'assets/icons/collect_yes.png'
                      : 'assets/icons/collect_no.png',
                  height: 22,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _hasError && !_isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('页面加载失败', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('请检查网址是否正确', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : SafeArea(child: WebViewWidget(controller: controller)),
    );
  }

  void _showErrorPage() {
    ZzLoading.dismiss();
    setState(() {
      _hasError = true;
    });
  }
}
