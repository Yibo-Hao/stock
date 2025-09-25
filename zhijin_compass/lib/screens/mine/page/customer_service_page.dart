import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/tools/ZzCustomDialog.dart';
import 'package:zhijin_compass/tools/ZzPermissionTool.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'package:zhijin_compass/ztool/ztool_color.dart';

class CustomerServicePage extends StatefulWidget {
  const CustomerServicePage({super.key});

  @override
  State<CustomerServicePage> createState() => _CustomerServicePageState();
}

class _CustomerServicePageState extends State<CustomerServicePage> {
  String _imageUrl = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getImageUrl();
  }

  Future<void> _saveImage() async {
    if (_imageUrl.isEmpty) return;

    try {
      ZzLoading.show();
      // // 请求存储权限
      // var status = await Permission.storage.request();
      // if (!status.isGranted) {
      //   ZzLoading.showMessage('需要存储权限才能保存图片');
      //   return;
      // }

      // 下载图片
      final response = await http.get(Uri.parse(_imageUrl));
      if (response.statusCode != 200) {
        ZzLoading.showMessage('图片下载失败');
        return;
      }

      // 保存到相册
      final result = await ImageGallerySaverPlus.saveImage(
        response.bodyBytes,
        quality: 100,
        name: '客服二维码_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        ZzLoading.showMessage('图片保存成功');
      } else {
        ZzLoading.showMessage('图片保存失败');
      }
    } catch (e) {
      ZzLoading.showMessage('保存失败: ${e.toString()}');
    }
  }

  _getImageUrl() {
    ZzLoading.show();
    HttpUtil.getInstance().get(
      "/userCenter/customerPictures",
      successCallback: (data) {
        ZzLoading.dismiss();
        setState(() {
          _imageUrl = data ?? '';
        });
      },
      errorCallback: (errorCode, errorMsg) {
        ZzLoading.showMessage(errorMsg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZzColor.whiteColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 247, 213, 181),
                Color.fromARGB(178, 247, 213, 181),
              ],
            ),
          ),
        ),
        leading: null,
        automaticallyImplyLeading: false,
        // pinned: true,
        primary: true,
        // floating: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 80,
              height: 80,
              child: InkWell(
                highlightColor: Colors.transparent,
                onTap: () {
                  safeGoback(context);
                },
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image(
                      image: const AssetImage('assets/icons/nav_back.png'),
                      width: 18,
                      height: 18,
                      color: ZzColor.blackColor,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ignore: avoid_unnecessary_containers
                Container(
                  child: Text(
                    "联系客服",
                    style: TextStyle(
                      color: ZzColor.color_111111,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(),
              ],
            ),
            // ignore: avoid_unnecessary_containers
            SizedBox(width: 80, height: 80, child: Container()),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(178, 247, 213, 181),
              Color.fromARGB(69, 255, 167, 85),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 50),
            Image.asset('assets/images/kefu_add.png', height: 30),
            SizedBox(height: 20),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 200,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/kefu_phone.png',
                          width: 157,
                          height: 261,
                        ),
                        Positioned(
                          top: 120,
                          left: 48,

                          child: Image.asset(
                            'assets/images/kefu_weixin.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: 230,
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xffFF782E), Color(0xffFFA755)],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            width: 200,
                            height: 200,
                            decoration: ZzDecoration.onlyradius(
                              5,
                              ZzColor.whiteColor,
                            ),
                            child: zZNetImage(
                              _imageUrl,
                              placeholder: Center(child: Text("loading...")),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 20),
                            width: 120,
                            height: 40,
                            decoration: ZzDecoration.onlyradius(
                              100,
                              ZzColor.whiteColor,
                            ),
                            child: InkWell(
                              onTap: _saveImage,
                              child: Text(
                                "保存图片",
                                style: ZzFonts.fontByBase(
                                  16,
                                  Color(0xffF1525B),
                                  FontWeight.w500,
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
      ),
    );
  }
}
