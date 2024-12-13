import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/example_controller.dart';

class Simple extends GetView<ExampleController> {
  static const routeName = '/simple';
  const Simple({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
