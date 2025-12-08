import 'package:get/get.dart';

import '../pages/splash/view/splash_page.dart';
import 'app_const.dart';
import 'theme.dart';

class ThemeController extends GetxController {
  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = box.read(Spf.isDarkMode) ?? false;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(
      isDarkMode.value
          ? MaterialTheme.constant.dark()
          : MaterialTheme.constant.light(),
    );
    box.write('isDarkMode', isDarkMode.value);
    Get.offAllNamed(Splash.route);
  }
}