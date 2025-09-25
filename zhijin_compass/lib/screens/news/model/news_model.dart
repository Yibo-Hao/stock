import 'package:flutter/rendering.dart';

class NewsModel {
  String? url;
  String? dlUrl;
  String? ctime;
  String? title;
  String? media;
  List<String>? thumb;
  bool? ad;

  NewsModel({
    this.url,
    this.dlUrl,
    this.ctime,
    this.title,
    this.media,
    this.thumb,
    this.ad,
  });

  NewsModel.fromJson(Map<String, dynamic> json) {
    // 处理url参数，提取url参数中的值
    // final originalUrl = json['url']?.toString() ?? '';
    // url = originalUrl; // 默认值

    // try {
    //   // 处理哈希(#)后的参数
    //   final hashIndex = originalUrl.indexOf('#');
    //   if (hashIndex != -1) {
    //     final fragment = originalUrl.substring(hashIndex + 1);
    //     if (fragment.contains('?')) {
    //       final queryStart = fragment.indexOf('?');
    //       final queryString = fragment.substring(queryStart + 1);
    //       final params = Uri.splitQueryString(queryString);
    //       if (params.containsKey('url')) {
    //         url = params['url']!;
    //         debugPrint('成功从片段中提取url: $url');
    //       }
    //     }
    //   }

    //   // 检查主查询参数
    //   final uri = Uri.parse(originalUrl);
    //   if (uri.queryParameters.containsKey('url')) {
    //     url = uri.queryParameters['url']!;
    //     debugPrint('成功从主查询参数中提取url: $url');
    //   }
    // } catch (e) {
    //   debugPrint('解析url失败: $e');
    // }
    url = json['url'] + "&source=channel_dl003&link_from=dl";
    dlUrl = json['dlUrl'];
    ctime = json['ctime'];
    title = json['title'];
    media = json['media'];
    thumb = json['thumb'].cast<String>();
    ad = json['ad'];
  }
}
