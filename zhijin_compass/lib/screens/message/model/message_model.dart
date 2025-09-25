class MessageModel {
  num? id;
  num? uid;
  String? type;
  String? content;
  bool? isRead;
  String? createTime;
  String? updateTime;

  MessageModel({
    this.id,
    this.uid,
    this.type,
    this.content,
    this.isRead,
    this.createTime,
    this.updateTime,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    type = json['type'];
    content = json['content'];
    isRead = json['isRead'];
    createTime = json['createTime'];
    updateTime = json['updateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['type'] = this.type;
    data['content'] = this.content;
    data['isRead'] = this.isRead;
    data['createTime'] = this.createTime;
    data['updateTime'] = this.updateTime;
    return data;
  }
}
