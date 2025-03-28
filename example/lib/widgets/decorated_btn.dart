import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DecoratedBtn extends StatelessWidget {
  final VoidCallback? onPress;
  final String text;
  final double? radius;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? textColor;
  final Color? borderColor;

  const DecoratedBtn({
    super.key,
    required this.onPress,
    required this.text,
    this.radius,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        maximumSize: Size(Get.width, 45),
        minimumSize: Size(Get.width * .3, 25),
        fixedSize: Size(width ?? Get.width, height ?? 40),
        backgroundColor:
            backgroundColor ?? Get.theme.colorScheme.primaryContainer,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 25),
        ),
        side: BorderSide(
          style: BorderStyle.solid,
          width: 1,
          color: borderColor ?? Get.theme.colorScheme.primaryContainer,
        ),
      ),
      onPressed: onPress,
      child: Text(
        text,
        style: Get.textTheme.labelLarge!
            .copyWith(color: textColor ?? Get.theme.colorScheme.onPrimary),
      ),
    );
  }
}
