class UserModel {
  num? id;
  String? username;
  String? mobile;
  String? status;
  bool? allowPush;
  bool? pushSystemMessage;
  String? createTime;
  String? updateTime;

  UserModel({
    this.id,
    this.username,
    this.mobile,
    this.status,
    this.allowPush,
    this.pushSystemMessage,
    this.createTime,
    this.updateTime,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    mobile = json['mobile'];
    status = json['status'];
    allowPush = json['allowPush'];
    pushSystemMessage = json['pushSystemMessage'];
    createTime = json['createTime'];
    updateTime = json['updateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['mobile'] = this.mobile;
    data['status'] = this.status;
    data['allowPush'] = this.allowPush;
    data['pushSystemMessage'] = this.pushSystemMessage;
    data['createTime'] = this.createTime;
    data['updateTime'] = this.updateTime;
    return data;
  }
}
