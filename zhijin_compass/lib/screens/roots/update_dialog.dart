import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/tools/ZzCustomDialog.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

class UpdateDialog {
  static Future<void> checkAndShowUpdateDialog(BuildContext context) async {
    final data = await _getUpdateInfo();
    if (data == null) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final version = '${packageInfo.version} (${packageInfo.buildNumber})'
        .replaceAll(RegExp(r'\(\d+\)'), '');

    // ignore: use_build_context_synchronously
    _showUpdateDialog(context, data, version);
  }

  static Future<Map<String, dynamic>?> _getUpdateInfo() async {
    var datas = {};
    try {
      await HttpUtil.getInstance().get(
        "/user/updatePopupInfo",
        successCallback: (data) {
          datas = data;
        },
        errorCallback: (errorCode, errorMsg) {},
      );
    } catch (e) {
      ZzLoading.showMessage("获取更新信息失败");
    }
    return datas as Map<String, dynamic>?;
  }

  static void _showUpdateDialog(
    BuildContext context,
    Map<String, dynamic> data,
    String currentVersion,
  ) {
    if (!data['enableUpdatePopup']) return;

    final forceVersion = data['forceUpdateMinVersion'];
    final recommendVersion = data['recommendUpdateMinVersion'];

    final isForceUpdate =
        forceVersion != null &&
        forceVersion.isNotEmpty &&
        _compareVersions(currentVersion, forceVersion) < 0;

    final isRecommendUpdate =
        recommendVersion != null &&
        recommendVersion.isNotEmpty &&
        _compareVersions(currentVersion, recommendVersion) < 0;

    if (!isForceUpdate && !isRecommendUpdate) return;

    ZzCustomDialog.show(
      context: context,
      image: Positioned(
        top: -75,
        left: 0,
        right: 0,
        child: Image.asset('assets/images/dialog_warnning.png', height: 150),
      ),
      barrierDismissible: !isForceUpdate,
      content: isForceUpdate
          ? data['forceUpdateText']
          : data['recommendUpdateText'],
      singleButton: isForceUpdate,
      leftButtonText: isForceUpdate ? '' : "暂不更新",
      rightButtonText: isForceUpdate ? "立即更新" : "去更新",
      rightButtonAction: () async {
        final url = isForceUpdate
            ? data['forceUpdateUrl']
            : data['recommendUpdateUrl'];
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          ZzLoading.showMessage('无法打开下载链接');
        }
      },
    );
  }

  static int _compareVersions(String version1, String version2) {
    try {
      final v1 = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final v2 = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < v1.length; i++) {
        if (i >= v2.length) return 1;
        if (v1[i] < v2[i]) return -1;
        if (v1[i] > v2[i]) return 1;
      }

      return v1.length == v2.length ? 0 : -1;
    } catch (e) {
      debugPrint('版本比较出错: $e');
      return 0;
    }
  }
}
