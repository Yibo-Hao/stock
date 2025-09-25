import 'package:flutter/material.dart';
import 'package:zhijin_compass/ztool/ztool.dart';
import 'package:zhijin_compass/ztool/ztool_color.dart';

class MenuItemWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;
  final bool isEnd;

  const MenuItemWidget({
    super.key,
    required this.iconPath,
    required this.title,
    this.trailingText,
    required this.onTap,
    this.isEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(iconPath, height: 23),
                    SizedBox(width: 10),
                    Text(title, style: ZzFonts.fontNormal333(15)),
                  ],
                ),
                Row(
                  children: [
                    if (trailingText != null)
                      Text(trailingText!, style: ZzFonts.fontNormal111(13)),
                    SizedBox(width: 10),
                    Image.asset('assets/icons/arrow_right.png', height: 15),
                  ],
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: !isEnd,
          child: Divider(height: 30, color: ZzColor.lineColor),
        ),
      ],
    );
  }
}
