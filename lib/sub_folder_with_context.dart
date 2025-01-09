class SubFoldersWithContentClass {
  static String folderName = '';

  static final subFoldersWithContent = {
    'view': '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/${folderName}_controller.dart';

class ${_capitalize(folderName)} extends GetView<${_capitalize(folderName)}Controller> {
  static const route = '/$folderName';
  const ${_capitalize(folderName)} ({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
    'controller': '''
import 'package:get/get.dart';

import '../model/${folderName}_model.dart';

class ${_capitalize(folderName)}Controller extends GetxController with StateMixin<${_capitalize(folderName)}Model> {

}
''',
    'model': '''
class ${_capitalize(folderName)}Model {
  
}
''',
    'provider': '''
class ${_capitalize(folderName)}Provider {
  
}
''',
    'binding': '''
import 'package:get/get.dart';

import '../controller/${folderName}_controller.dart';
import '../provider/${folderName}_provider.dart';

class ${_capitalize(folderName)}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ${_capitalize(folderName)}Controller());
    Get.lazyPut(() => ${_capitalize(folderName)}Provider());
  }
}
'''
  };
}

String _capitalize(String input) {
  return input.split('_').map((part) {
    return part[0].toUpperCase() + part.substring(1);
  }).join('');
}
