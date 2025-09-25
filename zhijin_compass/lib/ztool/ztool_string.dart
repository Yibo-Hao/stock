import 'dart:convert';
import 'dart:math';

getTitleFromList(List list, value) {
  return list.firstWhere(
    (element) => element["value"] == value,
    orElse: () => list[0],
  )["title"];
}

///字符串处理工具类
class ZzString {
  /// 把字符串转换为密文字符
  /// [str] 原始字符串
  /// [start] 起始下标，下标从0开始
  /// [len] 要转换的字符数
  static String obscureStr({
    required String str,
    required int start,
    required int len,
    String single = "*",
  }) {
    if (str == "null" || str.isEmpty) {
      return "";
    }
    if (start < 0 || start + len > str.length) {
      return str;
    }

    ///生成密文字符串
    StringBuffer obsStr = StringBuffer();
    for (int i = 0; i < len; i++) {
      obsStr.write(single);
    }

    return str.replaceRange(start, start + len, obsStr.toString());
  }

  static String getLastFourChars(String str, int lenght) {
    // 检查字符串长度是否大于等于lenght
    if (str.length >= lenght) {
      // 截取最后四位字符
      return str.substring(str.length - lenght);
    } else {
      // 如果字符串长度小于lenght，返回整个字符串
      return str;
    }
  }

  ///判断APP是否有新版本
  static bool checkAPKNumber(version1, version2) {
    List<String> arr1 = version1.split(".");
    List<String> arr2 = version2.split(".");
    int length = max(arr1.length, arr2.length);
    for (int i = 0; i < length; i++) {
      int n1 = arr1.length > i ? int.parse(arr1[i]) : 0;
      int n2 = arr2.length > i ? int.parse(arr2[i]) : 0;
      if (n1 > n2) return false;
      if (n1 < n2) return true;
    }
    return false;
  }

  ///判断字符串是空的 ""也是空
  ///[str] 需要判断的字符串
  static isEmpty(String? str) {
    return str?.isEmpty ?? true;
  }

  ///判断字符串非空 ""也是空
  ///[str] 需要判断的字符串
  static isNotEmpty(String? str) {
    return str?.isNotEmpty ?? false;
  }

  ///验证手机号是否正确
  ///[str] 手机号码 11位
  static bool isPhoneNum(String str) {
    return RegExp(
      r'^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$',
    ).hasMatch(str);
  }

  ///验证身份证号是否正确
  ///[str] 18位身份证号
  static bool isIdCardNum(String str) {
    return RegExp(
      r'^([1-6][1-9]|50)\d{4}(18|19|20)\d{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$',
    ).hasMatch(str);
  }

  ///验证港澳通行证
  /// 规则： H/M + 10位或6位数字
  ///[str] 港澳通行证
  static bool isHKCardNum(String str) {
    return RegExp(r'^([A-Z]\d{6,10}(\(\w{1}\))?)$').hasMatch(str);
  }

  ///方法,传入数字,返回字符串 单位有 元  百  千  万 亿 (保留小数点后两位)
  /*
  输入值	输出示例	说明
123456789	"1.23亿"	自动选择最大单位（亿）
123456	"12.35万"	保留两位小数
1234	"1.23千"	自动降级单位
123	"123元"	小于百元时显示“元”
0.5	"0.50元"	小于1元时补零
null	"0.00"	空值处理
  */
  static String formatMoney(num? num) {
    if (num == null) return "0.00";

    // 定义单位阈值（单位：元）
    const Map<String, double> thresholds = {
      '亿': 100000000.0,
      '万': 10000.0,
      '千': 1000.0,
      '百': 100.0,
      '元': 1.0,
    };

    // 从大到小遍历单位，找到第一个满足条件的单位
    for (var entry in thresholds.entries) {
      final unit = entry.key;
      final threshold = entry.value;

      if (num.abs() >= threshold) {
        final value = num / threshold;
        // 处理整数情况（如 100元 → "100元" 而非 "100.00元"）
        return value % 1 == 0
            ? '${value.toInt()}$unit'
            : '${value.toStringAsFixed(2)}$unit';
      }
    }

    // 小于1元的情况（如0.5元 → "0.50元"）
    return '${num.toStringAsFixed(2)}元';
  }

  /// 台湾居民来往大陆通行证
  /// 规则： 新版8位或18位数字， 旧版10位数字 + 英文字母
  /// [str] 台湾居民来往大陆通行证
  static bool isTWCardNum(String str) {
    return RegExp(r'^\d{8}|^[a-zA-Z0-9]{10}|^\d{18}$').hasMatch(str);
  }

  /// 护照正则表达式
  /// 规则： 14/15开头 + 7位数字, G + 8位数字, P + 7位数字, S/D + 7或8位数字,等
  ///   /// [str] 护照号
  static bool isPassportNum(String str) {
    return RegExp(r'^([a-zA-z]|[0-9]){5,17}$').hasMatch(str);
  }

  /// 军官证
  /// 规则： 军/兵/士/文/职/广/（其他中文） + "字第" + 4到8位字母或数字 + "号"
  ///   /// [str] 军官证号
  static bool isOfficerCard(String str) {
    return RegExp(r'^[\u4E00-\u9FA5](字第)([0-9a-zA-Z]{4,8})(号?)$').hasMatch(str);
  }

  ///验证是否是邮箱
  static bool isEmail(String str) {
    return RegExp(
      r'\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$',
    ).hasMatch(str);
  }

  ///账号是否合法
  ///规则:字母开头，允许5-16字节，允许字母数字下划线
  static bool isLegalAccent(String str) {
    return RegExp(r'[a-zA-Z][a-zA-Z0-9_]{4,15}$').hasMatch(str);
  }

  ///弱密码
  ///规则:以字母开头，长度在6~18之间，只能包含字母、数字和下划线
  static bool isWeakPwd(String str) {
    return RegExp(r'[a-zA-Z]\w{5,17}$').hasMatch(str);
  }

  ///强密码
  ///规则:必须包含大小写字母和数字的组合，可以使用特殊字符，长度在8-10之间
  static bool isStrongPwd(String str) {
    return RegExp(r'(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,10}$').hasMatch(str);
  }

  ///QQ号
  /// QQ号以10000开始
  static bool isQQNum(String str) {
    return RegExp(r'[1-9][0-9]{4,} ').hasMatch(str);
  }

  static bool isPostalCode(String str) {
    return RegExp(r'[1-9]\d{5}(?!\d)').hasMatch(str);
  }

  ///清除所有的空格
  static String cleanAllSpace(String? str) {
    if (ZzString.isEmpty(str)) {
      return "";
    }
    return str!.replaceAll(RegExp(r"\s+\b|\b\s"), "");
  }

  ///字符串转map
  static Map stringtomap(str) {
    if (ZzString.isEmpty(str)) {
      return {};
    }
    try {
      Map map = jsonDecode(str);
      return map;
    } catch (e) {
      return {};
    }
  }
}
