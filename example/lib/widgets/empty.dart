import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Empty extends StatelessWidget {
  final String? message;
  const Empty({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message ?? "Record မရှိပါ",
        style: Get.textTheme.bodyMedium?.copyWith(
          color: Get.theme.colorScheme.primary,
        ),
      ),
    );
  }
}
