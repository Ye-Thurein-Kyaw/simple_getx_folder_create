import 'package:get/get.dart';

import '../model/example_model.dart';
import '../provider/example_provider.dart';

class ExampleController extends GetxController with StateMixin<ExampleModel> {
  final ExampleProvider _exampleProvider = Get.find(); 
}
