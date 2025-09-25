class SearchModel {
  String? uniqueId;
  num? marketType;
  String? shortCode;
  String? standardCode;
  String? name;
  String? extraInfo;
  String? nameExtra;
  num? flag1;
  num? flag2;
  String? extra1;
  String? extra2;
  String? extra3;

  SearchModel({
    this.uniqueId,
    this.marketType,
    this.shortCode,
    this.standardCode,
    this.name,
    this.extraInfo,
    this.nameExtra,
    this.flag1,
    this.flag2,
    this.extra1,
    this.extra2,
    this.extra3,
  });

  SearchModel.fromJson(Map<String, dynamic> json) {
    uniqueId = json['uniqueId'];
    marketType = json['marketType'];
    shortCode = json['shortCode'];
    standardCode = json['standardCode'];
    name = json['name'];
    extraInfo = json['extraInfo'];
    nameExtra = json['nameExtra'];
    flag1 = json['flag1'];
    flag2 = json['flag2'];
    extra1 = json['extra1'];
    extra2 = json['extra2'];
    extra3 = json['extra3'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uniqueId'] = this.uniqueId;
    data['marketType'] = this.marketType;
    data['shortCode'] = this.shortCode;
    data['standardCode'] = this.standardCode;
    data['name'] = this.name;
    data['extraInfo'] = this.extraInfo;
    data['nameExtra'] = this.nameExtra;
    data['flag1'] = this.flag1;
    data['flag2'] = this.flag2;
    data['extra1'] = this.extra1;
    data['extra2'] = this.extra2;
    data['extra3'] = this.extra3;
    return data;
  }
}
