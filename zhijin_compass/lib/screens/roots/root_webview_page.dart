import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

class ProtocolWebViewPage extends StatefulWidget {
  final String url;
  final String title;
  final bool isNeedAppBar;
  const ProtocolWebViewPage({
    Key? key,
    required this.url,
    required this.title,
    required this.isNeedAppBar,
  }) : super(key: key);

  @override
  State<ProtocolWebViewPage> createState() => _ProtocolWebViewPageState();
}

class _ProtocolWebViewPageState extends State<ProtocolWebViewPage> {
  bool isStartLoad = false;
  int _progress = 0;
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {
        isStartLoad = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isNeedAppBar
          ? ZzAppBar(
              title: widget.title,
              rightIcon: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20.0.rpx, // 设置指示器的宽度
                        height: 20.0.rpx, // 设置指示器的高度
                        child: CircularProgressIndicator(
                          value: _progress > 0
                              ? (_progress / 100).toDouble()
                              : null,
                          strokeWidth: 4.0, // 设置指示器的线宽度
                          backgroundColor: ZzColor.colorToFFF1EB, // 设置指示器的背景颜色
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ZzColor.mainAppColor,
                          ), // 设置指示器的颜色
                        ),
                      ),
                    )
                  : Container(),
            )
          : null,
      backgroundColor: ZzColor.pageBackGround,
      body: SafeArea(top: true, bottom: false, child: Container()),
    );
  }
}
/**/