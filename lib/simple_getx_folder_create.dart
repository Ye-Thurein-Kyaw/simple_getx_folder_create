// ignore_for_file: avoid_print

import 'dart:io';

import 'file_with_content.dart';
import 'sub_folder_with_context.dart';

/// Creates the base folder structure for a GetX Flutter project.
///
/// Generates [lib/pages], [lib/network], [lib/utils], and [lib/widgets]
/// directories and writes all template files defined in
/// [FileWithContentClass.filesWithContent] into the target project.
///
/// Example:
/// ```dart
/// createBaseFolderStructure();
/// ```
void createBaseFolderStructure() {
  // Base directories
  final baseDirectories = [
    Directory('lib/pages'),
    Directory('lib/network'),
    Directory('lib/utils'),
    Directory('lib/widgets'),
  ];

  for (var dir in baseDirectories) {
    if (!dir.existsSync()) {
      try {
        dir.createSync(recursive: true);
        print('Created folder: ${dir.path}');
      } catch (e) {
        print('Error creating directory ${dir.path}: $e');
      }
    }
  }

  // Files and their content
  FileWithContentClass.filesWithContent.forEach((filePath, content) {
    final file = File(filePath);
    try {
      file.writeAsStringSync(content);
      print('Created file: $filePath');
    } catch (e) {
      print('Error creating file $filePath: $e');
    }
  });
}

/// Creates a GetX page module under `lib/pages/<folderName>`.
///
/// Generates five sub-folders and their corresponding Dart files:
/// - `view/<folderName>_page.dart`
/// - `controller/<folderName>_controller.dart`
/// - `model/<folderName>_model.dart`
/// - `provider/<folderName>_provider.dart`
/// - `binding/<folderName>_binding.dart`
///
/// Example:
/// ```dart
/// createPageFolderStructure('home');
/// ```
void createPageFolderStructure(String folderName) {
  final pagesDir = Directory('lib/pages');
  if (!pagesDir.existsSync()) {
    try {
      pagesDir.createSync(recursive: true);
      print('Created folder: ${pagesDir.path}');
    } catch (e) {
      print('Error creating pages directory: $e');
      return;
    }
  }

  final baseDir = Directory('${pagesDir.path}/$folderName');
  if (!baseDir.existsSync()) {
    try {
      baseDir.createSync();
      print('Created folder: ${baseDir.path}');
    } catch (e) {
      print('Error creating folder $folderName: $e');
      return;
    }
  }

  // Subfolders and their corresponding file contents
  SubFoldersWithContentClass.folderName = folderName;
  SubFoldersWithContentClass.subFoldersWithContent.forEach((folder, content) {
    final dir = Directory('${baseDir.path}/$folder');
    final File file;
    try {
      dir.createSync();
      print('Created folder: ${dir.path}');
      if (folder == 'view') {
        file = File('${dir.path}/${folderName}_page.dart');
      } else {
        file = File('${dir.path}/${folderName}_$folder.dart');
      }
      file.writeAsStringSync(content);
      print('Created file: ${file.path}');
    } catch (e) {
      print('Error creating folder or file in $folder: $e');
    }
  });
}

/// Overwrites `lib/main.dart` with a GetX + GetStorage bootstrapped app shell.
///
/// The generated file sets up [GetStorage], registers [ThemeController] and
/// [ApiService] via [Get], and wires [GetMaterialApp] with named routes and
/// light/dark theme support.
///
/// Example:
/// ```dart
/// updateMainDart();
/// ```
void updateMainDart() {
  const mainDartTemplate = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'network/api_service.dart';
import 'pages/splash/view/splash_page.dart';
import 'utils/routes.dart';
import 'utils/theme.dart';
import 'utils/theme_controller.dart';

void main() async {
  await GetStorage.init();
  Get.lazyPut(() => ThemeController());
  Get.put(ApiService());
  Get.put(const MaterialTheme(TextTheme()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: Get.find<ThemeController>().isDarkMode.value
                      ? ThemeMode.dark
                      : ThemeMode.light,
      theme: MaterialTheme.constant.light(),
      darkTheme: MaterialTheme.constant.dark(),
      highContrastDarkTheme: MaterialTheme.constant.darkHighContrast(),
      highContrastTheme: MaterialTheme.constant.lightHighContrast(),
      getPages: getpages,
      initialRoute: Splash.route,
    );
  }
}

''';

  final mainFile = File('lib/main.dart');
  try {
    mainFile.writeAsStringSync(mainDartTemplate);
    print('Updated main.dart');
  } catch (e) {
    print('Error updating main.dart: $e');
  }
}
