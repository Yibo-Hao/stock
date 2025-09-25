import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/mine/widget/menu_item_widget.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/storages/sp_utils.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appName = '加载中...';
  String version = '加载中...';

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  Future<void> _getPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      version = 'v${packageInfo.version} (${packageInfo.buildNumber})';
      version = version.replaceAll(RegExp(r'\(\d+\)'), '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZzColor.pageBackGround,
      appBar: ZzAppBar(title: '关于我们'),
      bottomNavigationBar: Container(
        height: 100,
        child: Center(
          child: Text(
            "北京量子珊瑚科技有限公司\nCopyright@2025-2028 All Rights Reserved\n${BaseSpStorage.getInstance().deviceId}",
            textAlign: TextAlign.center,
            style: ZzFonts.fontNormal666(12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: ZzDecoration.onlyradius(8, ZzColor.whiteColor),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/banner_wait.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("$appName   $version", style: ZzFonts.fontNormal666(12)),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: ZzDecoration.onlyradius(8, ZzColor.whiteColor),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  MenuItemWidget(
                    iconPath: 'assets/images/mine_push_4.png',
                    title: '用户服务协议',
                    onTap: () {
                      safePushToPage(
                        context,
                        'base_webview_page',
                        arguments: {
                          "url": "${BaseUrl.webUrl}/contracts/agreement",
                          "title": "用户服务协议",
                        },
                      );
                    },
                  ),
                  // MenuItemWidget(
                  //   iconPath: 'assets/images/mine_push_5.png',
                  //   title: '隐私政策',
                  //   onTap: () {
                  //     safePushToPage(
                  //       context,
                  //       'base_webview_page',
                  //       arguments: {
                  //         "url": "www.hao123.com?Search",
                  //         "title": "隐私政策",
                  //       },
                  //     );
                  //   },
                  // ),
                  MenuItemWidget(
                    isEnd: true,
                    iconPath: 'assets/images/mine_push_3.png',
                    title: '个人信息保护协议',
                    onTap: () {
                      safePushToPage(
                        context,
                        'base_webview_page',
                        arguments: {
                          "url": "${BaseUrl.webUrl}/contracts/privacy-policy",
                          "title": "个人信息保护协议",
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: ZzDecoration.onlyradius(8, ZzColor.whiteColor),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  MenuItemWidget(
                    iconPath: 'assets/images/mine_push_2.png',
                    title: '个人信息收集清单',
                    onTap: () {
                      safePushToPage(
                        context,
                        'base_webview_page',
                        arguments: {
                          "url":
                              "${BaseUrl.webUrl}/contracts/privacy-collection-list",
                          "title": "个人信息收集清单",
                        },
                      );
                    },
                  ),
                  MenuItemWidget(
                    isEnd: true,
                    iconPath: 'assets/images/mine_push_1.png',
                    title: '第三方个人信息收集清单',
                    onTap: () {
                      safePushToPage(
                        context,
                        'base_webview_page',
                        arguments: {
                          "url": "${BaseUrl.webUrl}/contracts/sdk-collect-list",
                          "title": "第三方个人信息收集清单",
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
