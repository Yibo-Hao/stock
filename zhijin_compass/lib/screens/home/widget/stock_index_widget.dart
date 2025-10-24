import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:zhijin_compass/http_utils/http_utill.dart';
import 'package:zhijin_compass/ztool/ztool.dart';

class StockIndexWidget extends StatefulWidget {
  final List<String> symbols;
  final VoidCallback? onNewsTap;
  final bool isDoneBuild;

  const StockIndexWidget({
    super.key,
    required this.symbols,
    this.onNewsTap,
    this.isDoneBuild = false,
  });

  @override
  State<StockIndexWidget> createState() => _StockIndexWidgetState();
}

class _StockIndexWidgetState extends State<StockIndexWidget> {
  late WebSocketChannel _channel;
  late Map<String, dynamic> shData;
  late Map<String, dynamic> szData;
  late Map<String, dynamic> cybData;

  @override
  void initState() {
    super.initState();
    shData = {"name": "上证指数", "price": "0.00", "diff": "0.00", "chg": "0.00"};
    szData = {"name": "深证成指", "price": "0.00", "diff": "0.00", "chg": "0.00"};
    cybData = {"name": "创业板指", "price": "0.00", "diff": "0.00", "chg": "0.00"};
    _initSocket();
  }

  void _initSocket() async {
    try {
      final url = "wss://hq.sinajs.cn/wskt?list=${widget.symbols.join(',')}";
      _channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        headers: {
          'Origin': 'https://izq.sina.com.cn',
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36',
        },
      );

      _channel.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) => print('ws==>连接错误: $error'),
        onDone: () {
          // print('ws==>关闭连接');
          Future.delayed(Duration(seconds: 5), _initSocket);
        },
      );
    } catch (e) {
      print('ws==>尝试错误: $e');
      Future.delayed(Duration(seconds: 5), _initSocket);
    }
  }

  void _handleMessage(String message) {
    final stockList = message.split('\n')..removeLast();

    for (final subStr in stockList) {
      final subArr = subStr.split('=');
      final symbolName = subArr[0];
      final symbolDes = subArr[1];
      final symbolArr = symbolDes.split(',');

      final name = symbolArr[0];
      String price, diff, chg;

      if (double.parse(symbolArr[3]) == 0 && double.parse(symbolArr[8]) == 0) {
        price = double.parse(symbolArr[2]).toStringAsFixed(2);
        diff = (double.parse(symbolArr[2]) - double.parse(symbolArr[2]))
            .toStringAsFixed(2);
      } else {
        price = double.parse(symbolArr[3]).toStringAsFixed(2);
        diff = (double.parse(symbolArr[3]) - double.parse(symbolArr[2]))
            .toStringAsFixed(2);
      }

      chg = (100 * double.parse(diff) / double.parse(symbolArr[2]))
          .toStringAsFixed(2);

      final quotaionObj = {
        "name": name,
        "price": price,
        "diff": diff,
        "chg": chg,
      };

      setState(() {
        if (symbolName == "sh000001") {
          shData = quotaionObj;
        } else if (symbolName == "sz399001") {
          szData = quotaionObj;
        } else if (symbolName == "sz399006") {
          cybData = quotaionObj;
        }
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        image: DecorationImage(
          image: AssetImage('assets/images/home_static.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildIndexItem(shData),
                _buildIndexItem(szData),
                _buildIndexItem(cybData),
              ],
            ),
          ),
          if (widget.onNewsTap != null && widget.isDoneBuild)
            InkWell(
              onTap: widget.onNewsTap,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 15,
                  left: 8,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  children: [
                    Image.asset('assets/icons/hot.png', height: 30),
                    SizedBox(height: 3),
                    Text("头条", style: ZzFonts.fontNormal333(14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndexItem(Map<String, dynamic> item) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(item['name'], style: ZzFonts.fontNormal333(14)),
          SizedBox(height: 3),
          Text(
            item['price'] ?? "0.00",
            style: ZzFonts.fontByBase(
              15,
              ZZStockFormat.getColorByDiff(item["diff"]),
              FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                (double.parse(item["diff"]) > 0 ? '+' : '') + item["diff"],
                style: ZzFonts.fontByBase(
                  12,
                  ZZStockFormat.getColorByDiff(item["diff"]),
                  FontWeight.normal,
                ),
              ),
              SizedBox(width: 4),
              Text(
                (double.parse(item["chg"]) > 0 ? '+' : '') + item["chg"] + '%',
                style: ZzFonts.fontByBase(
                  12,
                  ZZStockFormat.getColorByDiff(item["diff"]),
                  FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
