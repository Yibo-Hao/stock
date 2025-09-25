package com.example.zhijin_compass

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.content.pm.PackageManager

class CustomFlutterActivity : FlutterActivity() {
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        // 处理权限请求结果
        when (requestCode) {
            // 添加您的特定权限请求码
            else -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // 权限被授予
                } else {
                    // 权限被拒绝
                    // 可以在这里添加处理逻辑，如显示提示或优雅降级
                }
            }
        }
    }
}