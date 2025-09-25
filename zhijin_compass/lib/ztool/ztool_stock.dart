/*
* 股票格式工具类
* */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zhijin_compass/ztool/ztool_color.dart';

class ZZStockFormat {
  /*
  *  涨跌幅
  *   入参数： "0.39"
  *   返回 "+0.39%"
  * */
  static String formatChg(String chg) {
    try {
      if (chg.isEmpty) {
        return '';
      }

      if (chg == '****') {
        return '****';
      }

      if (double.parse(chg) > 0) {
        return "+${double.parse(chg).toStringAsFixed(2)}%";
      }

      if (double.parse(chg) < 0) {
        return "${double.parse(chg).toStringAsFixed(2)}%";
      }

      return chg;
    } catch (e) {
      return chg;
    }
  }

  static String formatPercent(String chg) {
    try {
      if (chg.isEmpty) {
        return '';
      }

      if (chg == '****') {
        return '****';
      }

      return double.parse(chg).toStringAsFixed(2) + "%";
    } catch (e) {
      return chg;
    }
  }

  /*
  *  涨跌额
  *   入参数： "8.93""
  *   返回 "+8.93""
  * */
  static String formatDiff(String diff) {
    try {
      if (diff.isEmpty) {
        return '';
      }

      if (double.parse(diff) > 0) {
        return "+" + diff;
      }

      return diff;
    } catch (e) {
      return diff;
    }
  }

  static String formatSniper(String diff) {
    try {
      if (diff.isEmpty) {
        return '';
      }

      if (double.parse(diff) > 0) {
        return "+" + diff + '%';
      }

      return diff + '%';
    } catch (e) {
      return diff;
    }
  }

  /*
  * 红涨、绿跌、黑平
  * */
  static Color getColorByDiff(String diff) {
    try {
      if (diff.isEmpty) {
        return ZzColor.color_333333;
      }

      if (double.parse(diff) > 0) {
        return ZzColor.colorRise;
      }

      if (double.parse(diff) < 0) {
        return ZzColor.colorDown;
      }

      return ZzColor.color_333333;
    } catch (e) {
      return ZzColor.color_333333;
    }
  }

  /*
  * 红涨、绿跌、黑平
  * */
  static Color getColorByChg(String chg) {
    //    if (double.parse(chg) > 0) {
    //      return AppColors.color_rise;
    //    }else if (double.parse(chg) < 0) {
    //      return AppColors.color_down;
    //    }
    //    return AppColors.color_333333;

    return getColorByChgWithColor(
      chg,
      ZzColor.colorRise,
      ZzColor.colorDown,
      ZzColor.color_333333,
    ); // AppColors.color_8695B2
  }

  static Color getColorByHCD(String stutats) {
    //获取字体颜色[强,弱,中]
    if (stutats == '强') {
      return Color.fromRGBO(245, 24, 24, 1);
    } else if (stutats == '弱') {
      return Color.fromRGBO(84, 168, 84, 1);
    } else if (stutats == '中') {
      return Color.fromRGBO(255, 130, 0, 1);
    } else {
      return Color.fromRGBO(51, 51, 51, 1);
    }

    //return getColorByChgWithColor(chg, AppColors.color_rise,
    //  AppColors.color_down, AppColors.color_333333); // AppColors.color_8695B2
  }

  static Color getColorByChgWithColor(
    String chg,
    Color riseColor,
    Color downColors,
    Color defaultColors,
  ) {
    try {
      if (chg == null || chg.isEmpty) {
        return defaultColors;
      }

      if (double.parse(chg) > 0) {
        return riseColor;
      }

      if (double.parse(chg) < 0) {
        return downColors;
      }

      return defaultColors;
    } catch (e) {
      return defaultColors;
    }
  }

  /*
  * 获取股票icon图标
  * */
  static AssetImage getStockIcon(String symbol, {String securityType = "A"}) {
    if (securityType == "A") {
      return AssetImage(
        symbol.contains('sh')
            ? 'assets/newIcons/SH.png'
            : 'assets/newIcons/SZ.png',
      );
    } else if (securityType == "Z") {
      return AssetImage('assets/newIcons/ZQ.png');
    } else if (securityType == "E") {
      return AssetImage('assets/newIcons/OF.png');
    } else {
      return AssetImage(
        symbol.contains('sh')
            ? 'assets/newIcons/SH.png'
            : 'assets/newIcons/SZ.png',
      );
    }
  }

  /*
  * 自选股获取icon
  * */
  static AssetImage getStockListIcon(String symbol, {String classType = "s"}) {
    if (classType == "z") {
      return AssetImage('assets/newIcons/icon_optional_zhai.png');
    }

    if (classType == "e") {
      return AssetImage('assets/newIcons/icon_optional_of.png');
    }

    return AssetImage(
      symbol.contains('sh')
          ? 'assets/newIcons/SH.png'
          : 'assets/newIcons/SZ.png',
    );
  }

  // 获取股票市场
  String getMarketWithResultType(String type) {
    String market = "";

    if (type.isEmpty) {
      return market;
    }

    switch (int.parse(type)) {
      case 11:
        {
          market = "cn";
          break;
        }
      case 22:
        {
          market = "cn";
          break;
        }
      case 81:
        {
          market = "cn";
          break;
        }
      case 82:
        {
          market = "cn";
          break;
        }
      case 120:
        {
          market = "cn";
          break;
        }
      case 31:
        {
          market = "hk";
          break;
        }
      case 33:
        {
          market = "hk";
          break;
        }
      case 41:
        {
          market = "us";
          break;
        }
      default:
        {}
        break;
    }
    return market;
  }

  //传入股票代码返回
  SplitModel getSplitStockModel(String symbol) {
    if (symbol.isNotEmpty) {
      //将symbol(sz000123) 拆分成两部分，第一部分是字母前缀，第二部分是数字代码
      //例如sz000123 拆分成两部分，第一部分是字母前缀sz，第二部分是数字代码000123
      RegExp exp = RegExp(r'([a-zA-Z]+)([0-9]+)');
      Match? match = exp.firstMatch(symbol);
      if (match == null) {
        return SplitModel(code: '******', prefix: "");
      }
      var prefix = match.group(1) ?? '';
      if (prefix.isNotEmpty) {
        //将字母前缀转换成大写
        prefix = prefix.toUpperCase();
      } else {
        prefix = "";
      }
      var code = match.group(2) ?? '******';
      return SplitModel.fromJson({
        'prefix': prefix, // 字母前缀
        'code': code, // 数字代码
      });
    }
    return SplitModel(code: '******', prefix: "");
  }

  //正则判断是否是英文字母
  bool isvalidateEnglish(String input) {
    RegExp alphabet = new RegExp(r"^[A-Za-z]+$");
    return alphabet.hasMatch(input);
  }

  // 获取股票市场类型
  String getSymbolTypeWithMarketAndSymbol(String market, String symbol) {
    String symbolType = "";
    if (market.isEmpty || symbol.isEmpty) {
      return symbolType;
    }
    symbolType = "S";
    if (market == "cn") {
      // 判断股票前缀是否是sh000，或是sz399
      if (symbol.contains("sh000") || symbol.contains("sz399")) {
        symbolType = "I";
      }
    } else if (market == "hk") {
      // 判断首字母是否是英文字母
      String firstStr = symbol.substring(0, 1);
      if (isvalidateEnglish(firstStr)) {
        symbolType = "I";
      }
    } else if (market == "us") {
      // 判断是否是 .dji(道琼斯) .ixic(纳斯达克) .inx(标普500)
      if (symbol == ".dji" || symbol == ".ixic" || symbol == ".inx") {
        symbolType = "I";
      }
    }
    return symbolType;
  }
}

class SplitModel {
  String? prefix;
  String? code;

  SplitModel({this.prefix, this.code});

  SplitModel.fromJson(Map<String, dynamic> json) {
    prefix = json['prefix'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['prefix'] = this.prefix;
    data['code'] = this.code;
    return data;
  }
}
