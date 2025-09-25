import 'package:event_bus/event_bus.dart';
import 'package:zhijin_compass/storages/user_model.dart';

EventBus zzEventBus = EventBus();

//用户信息更新通知
class UserInfoUpDateBus {
  UserModel? model;
  UserInfoUpDateBus({this.model});
}

//个人中心数据更新通知
class MineUpDataBus {
  MineUpDataBus();
}

//个人中心数据更新通知
class ProxySetSuccessBus {
  ProxySetSuccessBus();
}

//指定tabbar跳转index
class TabbarDidChangeBus {
  int index;
  TabbarDidChangeBus(this.index);
}

//tabbar切换通知
class TabbarOnChangeBus {
  int index;
  TabbarOnChangeBus(this.index);
}

//刷新派给我的数量
class AppointCountBus {
  AppointCountBus();
}

//订单刷新通知
class OrderUpDataBus {
  OrderUpDataBus();
}

//接受订单通知
class OrderacceptUpDataBus {
  OrderacceptUpDataBus();
}

//更改接单周期通知
class OrderCycleChangeBus {
  OrderCycleChangeBus();
}

//登录/退出登录通知
class LoginBus {
  bool islogin;
  UserModel? model;
  LoginBus(this.islogin, {this.model});
}

//静默刷新数据通知
class TabIndexChangeBus {
  int? index;
  TabIndexChangeBus(this.index);
}


// enum ActionClickEventType {
//   uploadPhoto, // 上传形象照
//   uploadPhotoAlert, // 上传形象照
//   donate, // 捐献
// }

// class ActionClickEvent {
//   ActionClickEventType index;
//   ActionClickEvent({required this.index});
// }

