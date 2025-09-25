import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/screens/roots/root_event_bus.dart';
import 'package:zhijin_compass/screens/search/model/new_stock_model.dart';
import 'package:zhijin_compass/storages/user_model.dart';
import 'package:zhijin_compass/ztool/ztool_safe.dart';

class BaseSpStorage extends GetxController {
  static BaseSpStorage? instance;
  late GetStorage box;

  static BaseSpStorage getInstance() {
    instance ??= BaseSpStorage();
    return instance!;
  }

  BaseSpStorage() {
    box = GetStorage();
    Future.delayed(Duration.zero, () {
      updateUserInfo();
      getServiceDataUrl();
    });
  }
  removeData(String key) {
    box.remove(key);
  }

  bool updateUserInfo() {
    if ($empty(box.read('token'))) return false;
    HttpUtil.getInstance().get(
      "/user/getUserInfo",
      successCallback: (data) {
        box.write('userModel', data);
        zzEventBus.fire(UserInfoUpDateBus(model: UserModel.fromJson(data)));
        box.write('phone', UserModel.fromJson(data).mobile);
        return true;
      },
      errorCallback: (errorCode, errorMsg) {},
    );
    return false;
  }

  void getServiceDataUrl() {
    // HttpUtil.getInstance().get(
    //   "/work-api/work/api/commons/customer/phone",
    //   successCallback: (data) {
    //     List<CommonsModel> list = List<CommonsModel>.from(
    //       data.map((it) => CommonsModel.fromJson(it)),
    //     );
    //     serviceList = list;
    //   },
    //   errorCallback: (errorCode, errorMsg) {},
    // );
  }

  void getadvertisingDataUrl() {
    // HttpUtil.getInstance().get(
    //   "/work-api/work/api/commons/banners",
    //   queryParameters: {"type": 2},
    //   successCallback: (data) {
    //     print("打印广告页数据2==$data");
    //     List list = data ?? [];
    //     print("打印广告页数据3==$list");
    //     box.write('advertisingList', list);
    //   },
    //   errorCallback: (errorCode, errorMsg) {},
    // );
  }

  //读取变量
  String get userToken => box.read('token') ?? "";
  List get advertisingList => box.read('advertisingList') ?? [];
  String get isAgreeProl => box.read('isareeprol') ?? "";
  String get isGetLocation => box.read('isgetLocation') ?? "";
  String get isSureRefuse => box.read('issurerefuse') ?? "";
  String get workWeeks => box.read('workWeeks') ?? "";
  String get mobile => box.read('phone') ?? "";
  String get avatar => box.read('avatar') ?? "";
  String get nickname => box.read('nickname') ?? "";
  String get jpushId => box.read('jpushId') ?? "";
  String get sex => box.read('sex') ?? "";
  String get proxy => box.read('proxy') ?? "";
  bool get isAutoLogin => box.read('isAutoLogin') ?? false;

  String get deviceId => box.read('deviceId') ?? "";
  bool get isdevelop => box.read('isdevelop') ?? false;
  Map get feedbackMap => box.read('feedbackMap') ?? {}; //意见反馈本地保存
  bool get isReleaseModel => kReleaseMode
      ? true
      : (box.read('isReleaseModel') ??
            true); //(box.read('isReleaseModel') ?? true)&&;
  UserModel? get userModel => box.read('userModel') != null
      ? UserModel.fromJson(box.read('userModel'))
      : null;

  String get localStockList => box.read('localStockList') ?? '';

  List<NewStockModel> get localStockModels {
    final jsonStr = box.read('localStockList');
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final jsonList = jsonDecode(jsonStr) as List;
      return jsonList.map((e) => NewStockModel.fromJson(e)).toList();
    } catch (e) {
      print('解析本地自选股错误: $e');
      return [];
    }
  }

  //写入数据
  void setUserToken(String userToken) => box.write('token', userToken);

  void setLocalStockModels(List<NewStockModel> stocks) {
    final jsonList = stocks.map((e) => e.toJson()).toList();
    box.write('localStockList', jsonEncode(jsonList));
  }

  void setproxy(String proxy) => box.write('proxy', proxy);
  void setAutoLogin(bool isAutoLogin) => box.write('isAutoLogin', isAutoLogin);
  void setdeviceId(String deviceId) => box.write('deviceId', deviceId);
  void setisdevelop(bool isdevelop) => box.write('isdevelop', isdevelop);
  void setIsAreeProl(String isareeprol) => box.write('isareeprol', isareeprol);
  void setIsGetLocation(String isgetlocation) =>
      box.write('isgetLocation', isgetlocation);
  void setisSureRefuse(String issurerefuse) =>
      box.write('issurerefuse', issurerefuse);
  void setWorkWeeks(String workWeeks) => box.write('workWeeks', workWeeks);
  void setfeedBackMap(Map feedBackMap) => box.write('feedbackMap', feedBackMap);
  void setUserMobile(String mobile) => box.write('phone', mobile);
  void setUserNickname(String nickname) => box.write('nickname', nickname);
  void setUserAvatar(String avatar) => box.write('avatar', avatar);
  void setjpushId(String jpushId) => box.write('jpushId', jpushId);
  void setUserSex(String sex) => box.write('sex', sex);
  void setUserModel(UserModel? userModel) =>
      box.write('userModel', userModel?.toJson());
  void cleanLocalStockList() => box.remove("localStockList");

  /// 兼容方法：将逗号分隔的字符串转换为NewStockModel列表
  List<NewStockModel> convertStringToStockModels(String stockString) {
    if (stockString.isEmpty) return [];
    return stockString
        .split(',')
        .map(
          (symbol) => NewStockModel(
            symbol: symbol,
            name: symbol, // 默认名称设为symbol，实际使用时可能需要从接口获取完整信息
          ),
        )
        .toList();
  }
}

class CommonsModel {
  num? id;
  num? pid;
  String? code;
  String? name;
  String? values;
  num? orderNum;
  num? status;
  String? imgUrl;
  String? iconUrl;
  String? createDate;

  CommonsModel({
    this.id,
    this.pid,
    this.code,
    this.name,
    this.values,
    this.orderNum,
    this.status,
    this.imgUrl,
    this.iconUrl,
    this.createDate,
  });

  CommonsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pid = json['pid'];
    code = json['code'];
    name = json['name'];
    values = json['values'];
    orderNum = json['orderNum'];
    status = json['status'];
    imgUrl = json['imgUrl'];
    iconUrl = json['iconUrl'];
    createDate = json['createDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pid'] = this.pid;
    data['code'] = this.code;
    data['name'] = this.name;
    data['values'] = this.values;
    data['orderNum'] = this.orderNum;
    data['status'] = this.status;
    data['imgUrl'] = this.imgUrl;
    data['iconUrl'] = this.iconUrl;
    data['createDate'] = this.createDate;
    return data;
  }
}
