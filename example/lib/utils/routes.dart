import 'package:get/get.dart';
import '../pages/splash/binding/splash_binding.dart';
import '../pages/splash/view/splash_page.dart';

List<GetPage> getpages = [
  GetPage(
    name: Splash.route,
    page: () => const Splash(),
    binding: SplashBinding(),
  ),
];
