import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/splash_controller.dart';

class Splash extends GetView<SplashController> {
  static const route = '/splash';
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to GetX Package,', style: TextStyle(fontSize: 24, color: Get.theme.primaryColor)),
            Text('Have a great day', style: TextStyle(fontSize: 12, color: Get.theme.colorScheme.primaryContainer)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Dark Mode => '),
                Obx(
                  () => Switch(
                    value: controller.themeController.isDarkMode.value,
                    onChanged: (value) => controller.themeController.toggleTheme(),
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Icon(Icons.brightness_2);
                      }
                      return null;
                    }),
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
