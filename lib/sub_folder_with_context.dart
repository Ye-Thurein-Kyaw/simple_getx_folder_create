/// Provides template file contents for a GetX page module's sub-folders.
///
/// Set [SubFoldersWithContentClass.folderName] before reading
/// [SubFoldersWithContentClass.subFoldersWithContent] so that class names
/// and import paths in the templates are correctly interpolated.
///
/// Example:
/// ```dart
/// SubFoldersWithContentClass.folderName = 'home';
/// SubFoldersWithContentClass.subFoldersWithContent.forEach((folder, content) {
///   // write content to lib/pages/home/<folder>/
/// });
/// ```
class SubFoldersWithContentClass {
  /// The name of the page module being scaffolded (e.g. `'home'`, `'splash'`).
  ///
  /// Must be set before accessing [subFoldersWithContent].
  static String folderName = '';

  /// A map of sub-folder names to their template Dart source content.
  ///
  /// Keys are sub-folder names (`view`, `controller`, `model`, `provider`,
  /// `binding`) and values are the Dart source strings written to disk.
  static final subFoldersWithContent = {
    'view': folderName == 'splash'
        ? '''
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
'''
        : '''
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
    'controller': folderName == 'splash'
        ? '''
import 'package:get/get.dart';

import '../../../utils/theme_controller.dart';
import '../model/splash_model.dart';

class SplashController extends GetxController with StateMixin<SplashModel> {
  final themeController = Get.find<ThemeController>();

}
'''
        : '''
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
