import 'package:get/get.dart';

import '../controller/example_controller.dart';
import '../provider/example_provider.dart';

class ExampleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExampleController());
    Get.lazyPut(() => ExampleProvider());
  }
}
