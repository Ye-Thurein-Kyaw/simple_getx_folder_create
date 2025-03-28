// ignore_for_file: avoid_print

import 'dart:io';
import 'package:args/args.dart';

import 'file_with_Content.dart';
import 'sub_folder_with_context.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('folder', abbr: 'f', help: 'Name of the page folder to create');
  final argResults = parser.parse(arguments);

  final setupFile = File('.setup_completed');

  if (!setupFile.existsSync()) {
    // install get and get_storage package
    _runCommand('flutter pub add get_storage');
    _runCommand('flutter pub add get');
    // Run the base setup only once
    createBaseFolderStructure();
    updateMainDart();
    print('Initial setup completed.');
  }

  if (argResults.wasParsed('folder')) {
    final folderName = argResults['folder'];
    if (folderName == null || folderName.isEmpty) {
      print('Folder name cannot be empty.');
      return;
    }
    createPageFolderStructure(folderName);
  } else {
    if (!setupFile.existsSync()) {
      createPageFolderStructure('splash');
      setupFile.writeAsStringSync('Base structure and main.dart updated.');
      print('Base structure and main.dart updated.');
      print('you need to change api_service.dart');
    } else {
      print(
          'No folder name provided. Please provide a folder name using the -f flag.');
    }
  }
}

void _runCommand(String command) {
  Process.run(command, [], runInShell: true).then((process) {
    if (process.exitCode == 0) {
      print('Command executed successfully');
    } else {
      print('Error executing command: ${process.stderr}');
    }
  });
}

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

void updateMainDart() {
  const mainDartTemplate = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'network/api_service.dart';
import 'pages/splash/view/splash_page.dart';
import 'utils/routes.dart';
import 'utils/theme.dart';

void main() async {
  await GetStorage.init();
  Get.put(ApiService());
  Get.put(const MaterialTheme(TextTheme()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.light,
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
