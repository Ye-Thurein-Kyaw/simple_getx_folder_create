import 'package:get/get.dart';

import '../controller/your_folder_name_controller.dart';
import '../provider/your_folder_name_provider.dart';

class Your_folder_nameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Your_folder_nameController());
    Get.lazyPut(() => Your_folder_nameProvider());
  }
}
