import 'package:flutter/material.dart';
import 'package:zhijin_compass/screens/roots/router_manager.dart';

import '../ztool/ztool.dart';

class ZzCustomDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final Widget? customContent;
  final Widget? image;
  final String leftButtonText;
  final String rightButtonText;
  final VoidCallback? leftButtonAction;
  final VoidCallback? rightButtonAction;
  final VoidCallback? closeButtonAction;
  final bool singleButton;

  const ZzCustomDialog({
    super.key,
    this.title,
    this.content,
    this.customContent,
    this.image,
    this.leftButtonText = '取消',
    this.rightButtonText = '确认',
    this.leftButtonAction,
    this.rightButtonAction,
    this.singleButton = false,
    this.closeButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      clipBehavior: Clip.none,
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        constraints: const BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFEDD3), Colors.white, Colors.white],
          ),
        ),
        width: ZzScreen().screenWidth - 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (image != null) image!,
            Container(
              color: const Color(0x00ffffff),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  if (image != null) const SizedBox(height: 40),
                  $notempty(title)
                      ? Padding(
                          padding: EdgeInsets.only(
                            bottom: 20,
                            left: 30,
                            right: 30,
                          ),
                          child: Text(
                            title ?? "",
                            style: ZzFonts.fontNormal111(22),
                          ),
                        )
                      : Padding(padding: EdgeInsets.only(bottom: 20)),

                  Visibility(
                    visible: $notempty(content),
                    child: Container(
                      padding: EdgeInsets.only(bottom: 20, left: 30, right: 30),
                      child: Text(
                        content ?? "",
                        textAlign: TextAlign.left,
                        style: ZzFonts.fontNormal333(14),
                      ),
                    ),
                  ),
                  if (customContent != null) customContent!,

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: singleButton
                        ? [
                            InkWell(
                              onTap:
                                  rightButtonAction ??
                                  () => safeGoback(context),
                              child: Container(
                                height: 45,
                                padding: EdgeInsets.symmetric(horizontal: 80),
                                decoration: ZzDecoration.onlyradius(
                                  100,
                                  ZzColor.mainAppColor,
                                ),
                                child: Center(
                                  child: Text(
                                    rightButtonText,
                                    style: ZzFonts.fontMediumWhite(14),
                                  ),
                                ),
                              ),
                            ),
                          ]
                        : [
                            InkWell(
                              onTap:
                                  leftButtonAction ?? () => safeGoback(context),
                              child: Container(
                                height: 45,
                                width: 120,
                                decoration: ZzDecoration.withborder(
                                  ZzColor.clearColor,
                                  1.5,
                                  ZzColor.mainAppColor,
                                  radius: 100,
                                ),
                                child: Center(
                                  child: Text(
                                    leftButtonText,
                                    style: ZzFonts.fontMediumMain(14),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap:
                                  rightButtonAction ??
                                  () => safeGoback(context),
                              child: Container(
                                height: 45,
                                width: 120,
                                decoration: ZzDecoration.onlyradius(
                                  100,
                                  ZzColor.mainAppColor,
                                ),
                                child: Center(
                                  child: Text(
                                    rightButtonText,
                                    style: ZzFonts.fontMediumWhite(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    String? title,
    Widget? image,
    String? content,
    Widget? customContent,
    String leftButtonText = '取消',
    String rightButtonText = '确认',
    VoidCallback? leftButtonAction,
    VoidCallback? rightButtonAction,
    VoidCallback? closeButtonAction,
    bool barrierDismissible = true,
    bool singleButton = false,
  }) {
    showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (context) => PopScope(
        canPop: barrierDismissible,
        child: ZzCustomDialog(
          title: title,
          content: content,
          customContent: customContent,
          image: image,
          leftButtonText: leftButtonText,
          rightButtonText: rightButtonText,
          leftButtonAction: leftButtonAction,
          rightButtonAction: rightButtonAction,
          closeButtonAction: closeButtonAction,
          singleButton: singleButton,
        ),
      ),
    );
  }
}
