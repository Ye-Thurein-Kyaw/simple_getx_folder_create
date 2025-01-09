import 'package:get/get.dart';

import '../controller/splash_controller.dart';
import '../provider/splash_provider.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
    Get.lazyPut(() => SplashProvider());
  }
}
