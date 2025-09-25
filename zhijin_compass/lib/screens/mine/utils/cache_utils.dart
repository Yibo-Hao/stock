import 'dart:io';
import 'dart:math';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class CacheUtils {
  // 获取应用缓存目录大小(仅计算临时目录)
  static Future<int> getCacheSize() async {
    try {
      // 只计算临时目录大小
      final tempDir = await getTemporaryDirectory();
      return await _getDirectorySize(tempDir);
    } catch (e) {
      return 0;
    }
  }

  // 计算目录大小
  static Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        final files = dir.listSync(recursive: true);
        for (final file in files) {
          if (file is File) {
            size += await file.length();
          }
        }
      }
    } catch (e) {
      print('Error calculating directory size: $e');
    }
    return (size / 3).round();
  }

  // 清除缓存(仅清理临时文件和图片缓存)
  static Future<void> clearCache() async {
    try {
      // 清理临时目录(保留token等关键数据)
      final tempDir = await getTemporaryDirectory();
      await _deleteDirectoryContents(
        tempDir,
        excludeExtensions: ['.token', '.json'],
      );

      // 清理图片缓存
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      print('Error clearing cache: $e');
      rethrow;
    }
  }

  // 删除目录内容(可排除特定扩展名的文件)
  static Future<void> _deleteDirectoryContents(
    Directory dir, {
    List<String> excludeExtensions = const [],
  }) async {
    try {
      if (await dir.exists()) {
        final files = dir.listSync(recursive: true);
        for (final file in files) {
          if (file is File) {
            // 检查文件扩展名是否在排除列表中
            final shouldDelete = excludeExtensions.every(
              (ext) => !file.path.endsWith(ext),
            );
            if (shouldDelete) {
              await file.delete();
            }
          } else if (file is Directory) {
            await _deleteDirectoryContents(
              file,
              excludeExtensions: excludeExtensions,
            );
          }
        }
      }
    } catch (e) {
      print('Error deleting directory contents: $e');
    }
  }

  // 格式化文件大小
  static String formatSize(int bytes) {
    //缓存小于500kb 返回空字符串
    if (bytes < 500 * 1024) return "";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)}${suffixes[i]}';
  }
}
