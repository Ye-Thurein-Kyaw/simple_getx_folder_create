// ignore_for_file: avoid_print

import 'dart:io';
import 'package:args/args.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('folder', abbr: 'f', help: 'Name of the root folder');

  final argResults = parser.parse(arguments);

  if (!argResults.wasParsed('folder')) {
    print('Please provide a folder name using -f or --folder');
    return;
  }

  final folderName = argResults['folder'];
  createFolderStructure(folderName);
}

void createFolderStructure(String folderName) {
  final pagesDir = Directory('lib/pages');

  // Ensure 'lib/pages' exists
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

  // Create the base folder
  if (!baseDir.existsSync()) {
    try {
      baseDir.createSync();
      print('Created folder: ${baseDir.path}');
    } catch (e) {
      print('Error creating folder $folderName: $e');
      return;
    }
  } else {
    print('Folder $folderName already exists.');
  }

  // Subfolders and their corresponding file contents
  final subFoldersWithContent = {
    'view': '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/${folderName}_controller.dart';

class Simple extends GetView<${_capitalize(folderName)}Controller> {
  static const routeName = '/simple';
  const Simple({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
    'controller': '''
import 'package:get/get.dart';

import '../model/${folderName}_model.dart';
import '../provider/${folderName}_provider.dart';

class ${_capitalize(folderName)}Controller extends GetxController with StateMixin<${_capitalize(folderName)}Model> {
  final ${_capitalize(folderName)}Provider _${folderName}Provider = Get.find(); 
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

  // Create subfolders and files with content
  subFoldersWithContent.forEach((folder, content) {
    final dir = Directory('${baseDir.path}/$folder');
    try {
      dir.createSync();
      print('Created folder: ${dir.path}');

      final file = File('${dir.path}/${folderName}_$folder.dart');
      file.writeAsStringSync(content);
      print('Created file: ${file.path}');
    } catch (e) {
      print('Error creating folder or file in $folder: $e');
    }
  });
}

String _capitalize(String input) {
  return input[0].toUpperCase() + input.substring(1);
}
