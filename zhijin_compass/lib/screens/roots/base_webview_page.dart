import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'package:flutter/scheduler.dart';

class BaseWebViewPage extends StatefulWidget {
  const BaseWebViewPage({super.key, this.url, this.title});
  final String? url;
  final String? title;

  @override
  State<BaseWebViewPage> createState() => _BaseWebViewPageState();
}

class _BaseWebViewPageState extends State<BaseWebViewPage>
    with SingleTickerProviderStateMixin {
  late final WebViewController controller;
  bool _isLoading = true;
  var _progress = 0;
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
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
            if (progress == 100) {
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
        ),
      );

    try {
      String url = widget.url.toString();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZzAppBar(
        title: widget.title ?? "详情",
        // rightIcon: SizedBox(
        //   child: SizedBox(
        //     width: 20.0.rpx, // 设置指示器的宽度
        //     height: 20.0.rpx, // 设置指示器的高度
        //     child: AnimatedBuilder(
        //       animation: _animationController,
        //       builder: (context, child) {
        //         return Transform.rotate(
        //           //防止默认的进度条太生硬,加个旋转动画
        //           angle: _animationController.value * 2 * 3.14159,
        //           child: CircularProgressIndicator(
        //             value: _progress > 0 ? (_progress / 100).toDouble() : null,
        //             strokeWidth: 4.0,
        //             backgroundColor: ZzColor.colorToFFF1EB,
        //             valueColor: AlwaysStoppedAnimation<Color>(
        //               ZzColor.mainAppColor,
        //             ),
        //           ),
        //         );
        //       },
        //     ),
        //   ),
        // ),
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
