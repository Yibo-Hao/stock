class HotSearchModel {
  String? market;
  String? symbolType;
  String? symbol;
  String? name;
  String? url;

  HotSearchModel({
    this.market,
    this.symbolType,
    this.symbol,
    this.name,
    this.url,
  });

  HotSearchModel.fromJson(Map<String, dynamic> json) {
    market = json['market'];
    symbolType = json['symbolType'];
    symbol = json['symbol'];
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['market'] = this.market;
    data['symbolType'] = this.symbolType;
    data['symbol'] = this.symbol;
    data['name'] = this.name;
    data['url'] = this.url;
    return data;
  }
}
