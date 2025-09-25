import 'package:flutter/material.dart';

import 'package:zhijin_compass/ztool/ztool.dart';

class DealPage extends StatefulWidget {
  const DealPage({super.key});

  @override
  State<DealPage> createState() => _DealPageState();
}

class _DealPageState extends State<DealPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        backgroundColor: ZzColor.mainAppColor,
        // pinned: true,
        elevation: 0.01,
        primary: true,
        // floating: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '证券交易',
              style: TextStyle(color: ZzColor.whiteColor, fontSize: 16),
            ),
          ],
        ),
      ),
      body: Container(
        //设置背景视图,上面有个80高的色块
        decoration: const BoxDecoration(color: ZzColor.pageBackGround),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xffF1525B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 300,
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/deal_wait.png'),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      // Container(
                      //   height: 300,
                      //   margin: const EdgeInsets.only(left: 10, right: 10),
                      //   decoration: BoxDecoration(
                      //     //渐变色
                      //     borderRadius: BorderRadius.all(Radius.circular(12)),
                      //     gradient: LinearGradient(
                      //       begin: Alignment.topCenter,
                      //       end: Alignment.bottomCenter,
                      //       stops: [0, 0.2],
                      //       colors: [
                      //         Color.fromRGBO(248, 180, 187, 1),
                      //         ZzColor.whiteColor,
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
