class NewStockModel {
  String? market;
  String? symbolType;
  String? symbol;
  String? name;
  String? price;
  String? diff;
  String? chg;
  String? securityType;
  bool? isSelectItem;

  NewStockModel({
    this.market,
    this.symbolType,
    this.symbol,
    this.name,
    this.price,
    this.diff,
    this.chg,
    this.securityType,
    this.isSelectItem,
  });

  NewStockModel.fromJson(Map<String, dynamic> json) {
    market = json['market'];
    symbolType = json['symbolType'];
    symbol = json['symbol'];
    name = json['name'];
    price = json['price'];
    diff = json['diff'];
    chg = json['chg'];
    securityType = json['securityType'];
    isSelectItem = json['isSelectItem'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['market'] = this.market;
    data['symbolType'] = this.symbolType;
    data['symbol'] = this.symbol;
    data['name'] = this.name;
    data['price'] = this.price;
    data['diff'] = this.diff;
    data['chg'] = this.chg;
    data['securityType'] = this.securityType;
    data['isSelectItem'] = this.isSelectItem;
    return data;
  }
}
