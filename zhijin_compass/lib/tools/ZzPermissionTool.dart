import 'dart:io';

import 'package:aliyun_push/aliyun_push.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';
import 'package:zhijin_compass/tools/ZzCustomDialog.dart';
import 'package:zhijin_compass/ztool/ztool_loading.dart';

enum PermissionType { sms, calendar, camera, notification, storage }

class ZzPermissionTool {
  // 单例实例
  static final ZzPermissionTool _instance = ZzPermissionTool._internal();

  // 私有构造函数
  ZzPermissionTool._internal();

  // 获取单例
  factory ZzPermissionTool() => _instance;

  // 权限类型枚举

  // 检查权限状态
  Future<PermissionStatus> checkPermission(PermissionType type) async {
    switch (type) {
      case PermissionType.sms:
        return await Permission.sms.status;
      case PermissionType.calendar:
        return await Permission.calendarFullAccess.status;
      case PermissionType.camera:
        return await Permission.camera.status;
      case PermissionType.notification:
        return await Permission.notification.status;
      case PermissionType.storage:
        return await Permission.storage.status;
    }
  }

  // 请求权限
  Future<PermissionStatus> requestPermission(PermissionType type) async {
    switch (type) {
      case PermissionType.sms:
        return await Permission.sms.request();
      case PermissionType.calendar:
        return await Permission.calendarFullAccess.request();
      case PermissionType.camera:
        return await Permission.camera.request();
      case PermissionType.notification:
        return await Permission.notification.request();
      case PermissionType.storage:
        return await Permission.storage.request();
    }
  }

  // 检查并请求权限，带拒绝回调
  Future<bool> checkAndRequestPermission(
    PermissionType type, {
    Function()? onDenied,
    Function()? onPermanentlyDenied,
  }) async {
    final status = await checkPermission(type);
    if (!status.isGranted) {
      final result = await requestPermission(type);
      if (result.isPermanentlyDenied && onPermanentlyDenied != null) {
        onPermanentlyDenied();
      } else if (result.isDenied && onDenied != null) {
        onDenied();
      }
      return result.isGranted;
    }
    return true;
  }

  // 批量请求权限，带拒绝回调
  Future<Map<PermissionType, bool>> requestPermissionsWithCallback(
    List<PermissionType> types, {
    Function(PermissionType)? onDenied,
    Function(PermissionType)? onPermanentlyDenied,
  }) async {
    final results = <PermissionType, bool>{};
    for (final type in types) {
      final status = await checkPermission(type);
      if (!status.isGranted) {
        final result = await requestPermission(type);
        if (result.isPermanentlyDenied && onPermanentlyDenied != null) {
          onPermanentlyDenied(type);
        } else if (result.isDenied && onDenied != null) {
          onDenied(type);
        }
        results[type] = result.isGranted;
      } else {
        results[type] = true;
      }
    }
    return results;
  }

  // 批量检查权限
  Future<Map<PermissionType, PermissionStatus>> checkPermissions(
    List<PermissionType> types,
  ) async {
    final results = <PermissionType, PermissionStatus>{};
    for (final type in types) {
      results[type] = await checkPermission(type);
    }
    return results;
  }

  // 批量请求权限
  Future<Map<PermissionType, PermissionStatus>> requestPermissions(
    List<PermissionType> types,
  ) async {
    final results = <PermissionType, PermissionStatus>{};
    for (final type in types) {
      results[type] = await requestPermission(type);
    }
    return results;
  }
}

Future<void> showPushPermissDialog(
  context,
  mounted, {
  Function()? onGranted,
}) async {
  // 先检查位置权限状态
  final status = await ZzPermissionTool().checkPermission(
    PermissionType.notification,
  );

  if (status.isGranted) {
    // 已有权限则直接返回
    return;
  }

  // 未授权则弹出确认对话框
  if (mounted) {
    ZzCustomDialog.show(
      context: context,
      barrierDismissible: false,
      closeButtonAction: () {
        safeGoback(context);
        //返回首页
      },
      leftButtonAction: () {
        safeGoback(context);
        //返回首页
      },
      image: Positioned(
        top: -110,
        left: 50,
        right: 0,
        child: Image.asset('assets/images/mine_notice_dialog.png', height: 150),
      ),
      title: "开启消息推送",
      content: '消息闪电送达 风向精准把握\n动态瞬间洞悉 先机一手掌控 ',
      rightButtonAction: () async {
        print("检测跳转===弹窗确认进入");
        // 用户确认后申请权限
        final result = await ZzPermissionTool().requestPermission(
          PermissionType.notification,
        );
        print("检测跳转===弹窗获取权限$result");

        if (result.isGranted && mounted) {
          if (onGranted != null) {
            onGranted();
          }
          safeGoback(context);
        } else if (result.isPermanentlyDenied) {
          // 权限被永久拒绝，引导用户到设置

          gotoPushSetting();
          safeGoback(context);
        } else if (result.isDenied) {
          //判断是否是华为设备

          if (await isHuaweiDevice() || await isRedmiDevice()) {
            gotoPushSetting();
          }
          // 用户拒绝后返回首页
          if (mounted) {
            safeGoback(context);
          }
        }
      },
    );
  }
}

Future<void> gotoPushSetting() async {
  jumpToNotificationSettingsMIUI();
}

/// 判断是否是华为设备
Future<bool> isHuaweiDevice() async {
  try {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      // 华为设备通常有以下特征：
      // 1. 制造商是HUAWEI
      // 2. 品牌是HUAWEI
      // 3. 型号以HUAWEI开头
      print(
        "检测跳转===判断是不是华为设备${androidInfo.manufacturer.toUpperCase().contains('HUAWEI') == true || androidInfo.brand.toUpperCase().contains('HUAWEI') == true || androidInfo.model.toUpperCase().startsWith('HUAWEI') == true}",
      );
      return androidInfo.manufacturer.toUpperCase().contains('HUAWEI') ==
              true ||
          androidInfo.brand.toUpperCase().contains('HUAWEI') == true ||
          androidInfo.model.toUpperCase().startsWith('HUAWEI') == true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

/// 判断是否是红米设备
Future<bool> isRedmiDevice() async {
  try {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      // 红米设备通常有以下特征：
      // 1. 品牌是Redmi或Xiaomi
      // 2. 型号以"Redmi"或"红米"开头
      // 3. 或者包含"Redmi"或"红米"字样
      final brand = androidInfo.brand.toUpperCase();
      final model = androidInfo.model.toUpperCase();
      print(
        "检测跳转===判断是不是红米设备${brand.contains('REDMI') || brand.contains('XIAOMI') || model.contains('REDMI') || model.contains('红米') || model.startsWith('REDMI') || model.startsWith('红米')}",
      );
      return brand.contains('REDMI') ||
          brand.contains('XIAOMI') ||
          model.contains('REDMI') ||
          model.contains('红米') ||
          model.startsWith('REDMI') ||
          model.startsWith('红米');
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<void> jumpToNotificationSettingsMIUI() async {
  print("检测跳转===跳转进入");

  try {
    // 尝试标准方式
    AliyunPush().jumpToAndroidNotificationSettings();
    print("检测跳转===跳转成功");
  } catch (e) {
    print("检测跳转===跳转失败进入");
    // MIUI特殊处理
    try {
      // 方案1: 直接跳转通知设置
      const scheme =
          'package:com.stock.zhijin_compass#Intent;action=android.settings.APP_NOTIFICATION_SETTINGS;end';
      if (await canLaunchUrl(Uri.parse(scheme))) {
        await launchUrl(Uri.parse(scheme));
        print("检测跳转===跳转失败方案1成功");
        return;
      }
      print("检测跳转===跳转失败方案1失败");

      // 方案2: 使用Intent方式
      final intent = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        data: 'package:com.stock.zhijin_compass',
      );
      await intent.launch();
      print("检测跳转===跳转失败方案2成功");
    } catch (e) {
      print("检测跳转===跳转失败方案2失败");
      // 方案3: 跳转到应用信息页
      try {
        final intent = AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:com.stock.zhijin_compass',
        );
        await intent.launch();
        print("检测跳转===跳转失败方案3成功");
      } catch (e) {
        // 最终方案: 使用系统默认方式
        print("检测跳转===跳转失败方案3失败");
        openAppSettings();
      }
    }
  }
}
