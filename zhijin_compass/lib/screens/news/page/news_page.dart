import 'package:animations/animations.dart'
    show OpenContainer, ContainerTransitionType;
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/src/smart_refresher.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/news/model/news_model.dart';
import 'package:zhijin_compass/screens/roots/base_webview_page.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late RefreshController _refreshController;
  int _pageNum = 1;
  // 条目总数
  final int _count = 20;
  List<NewsModel> _dataArr = [];

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _getNewsListUrl();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 200), () {
      _pageNum = 1;
      _getNewsListUrl();
    });
  }

  Future<void> _onLoad() async {
    await Future.delayed(const Duration(milliseconds: 200), () {
      _pageNum++;
      _getNewsListUrl();
    });
  }

  _getNewsListUrl() async {
    ZzLoading.show();
    HttpUtil.getInstance().get(
      "/news/indexNew",
      queryParameters: {"page": _pageNum, "num": _count},
      successCallback: (data) async {
        ZzLoading.dismiss();
        List clist = data ?? [];
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
        List<NewsModel> list = List<NewsModel>.from(
          clist.map((it) => NewsModel.fromJson(it)),
        );

        setState(() {
          if (_pageNum == 1) {
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
        ZzLoading.dismiss();
        _refreshController.loadFailed();
        _refreshController.refreshFailed();
        // ZzLoading.showMessage(errorMsg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () => safeGoback(context),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image(
                    image: const AssetImage('assets/icons/nav_back.png'),
                    width: 18,
                    height: 18,
                    color: ZzColor.whiteColor,
                  ),
                ),
              ),
            ),
            Text(
              '资讯头条',
              style: TextStyle(color: ZzColor.whiteColor, fontSize: 16),
            ),
            SizedBox(width: 80, height: 80),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
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
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            // decoration: BoxDecoration(
                            //   //渐变色
                            //   borderRadius: BorderRadius.all(Radius.circular(20)),
                            //   gradient: LinearGradient(
                            //     begin: Alignment.topCenter,
                            //     end: Alignment.bottomCenter,
                            //     stops: [0, 0.2],
                            //     colors: [
                            //       Color.fromRGBO(248, 180, 187, 1),
                            //       ZzColor.pageBackGround,
                            //     ],
                            //   ),
                            // ),
                            child: ZzRefresh(
                              refreshController: _refreshController,
                              onRefresh: () => _onRefresh(),
                              onLoading: () => _onLoad(),
                              child: CustomScrollView(
                                slivers: <Widget>[
                                  ..._dataArr.map(
                                    (item) => SliverToBoxAdapter(
                                      child: InkWell(
                                        onTap: () => safePushToPage(
                                          context,
                                          'base_webview_page',
                                          arguments: {
                                            "url": item.url ?? item.dlUrl,
                                            "title": item.title,
                                          },
                                        ),
                                        child: Container(
                                          decoration: ZzDecoration.onlyradius(
                                            10,
                                            ZzColor.whiteColor,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                          margin: EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 75,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.title ?? '',
                                                        style:
                                                            ZzFonts.fontMedium333(
                                                              15,
                                                            ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        "${item.media}  ${item.ctime}",
                                                        style:
                                                            ZzFonts.fontNormal666(
                                                              13,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Container(
                                                decoration:
                                                    ZzDecoration.onlyradius(
                                                      50,
                                                      ZzColor.whiteColor,
                                                    ),
                                                width: 120,
                                                height: 75,

                                                child: zZNetImage(
                                                  $notempty(item.thumb)
                                                      ? item.thumb![0]
                                                      : "assets/images/example_news.png",
                                                  fit: BoxFit.cover,
                                                  borderRadius: 2,
                                                ),
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
