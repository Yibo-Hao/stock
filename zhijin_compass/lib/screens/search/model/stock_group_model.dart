class StockGroupModel {
  num? id;
  num? uid;
  String? vcode;
  String? name;
  num? visable;
  num? isSystem;
  num? scope;
  num? position;
  String? createTime;
  String? updateTime;

  StockGroupModel({
    this.id,
    this.uid,
    this.vcode,
    this.name,
    this.visable,
    this.isSystem,
    this.scope,
    this.position,
    this.createTime,
    this.updateTime,
  });

  StockGroupModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    vcode = json['vcode'];
    name = json['name'];
    visable = json['visable'];
    isSystem = json['isSystem'];
    scope = json['scope'];
    position = json['position'];
    createTime = json['createTime'];
    updateTime = json['updateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['vcode'] = this.vcode;
    data['name'] = this.name;
    data['visable'] = this.visable;
    data['isSystem'] = this.isSystem;
    data['scope'] = this.scope;
    data['position'] = this.position;
    data['createTime'] = this.createTime;
    data['updateTime'] = this.updateTime;
    return data;
  }
}
