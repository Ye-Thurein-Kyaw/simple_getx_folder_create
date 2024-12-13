import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

void main() {
  const folderName = 'testModule';
  const basePath = 'lib/pages';
  final pagesDir = Directory(basePath);
  final baseDir = Directory(join(basePath, folderName));

  group('Folder Structure Generator', () {
    setUp(() {
      // Clean up before each test
      if (pagesDir.existsSync()) {
        pagesDir.deleteSync(recursive: true);
      }
    });

    test('Ensure base folder is created', () {
      createFolderStructure(folderName);
      expect(baseDir.existsSync(), isTrue);
    });

    test('Ensure subfolders are created', () {
      createFolderStructure(folderName);
      final subfolders = ['view', 'controller', 'model', 'provider', 'binding'];
      for (var subfolder in subfolders) {
        final subfolderPath = Directory(join(baseDir.path, subfolder));
        expect(subfolderPath.existsSync(), isTrue, reason: '$subfolder should exist');
      }
    });

    test('Ensure files are created with content', () {
      createFolderStructure(folderName);
      final subfolders = {
        'view': 'view/${folderName}_view.dart',
        'controller': 'controller/${folderName}_controller.dart',
        'model': 'model/${folderName}_model.dart',
        'provider': 'provider/${folderName}_provider.dart',
        'binding': 'binding/${folderName}_binding.dart',
      };

      subfolders.forEach((subfolder, filePath) {
        final file = File(join(baseDir.path, filePath));
        expect(file.existsSync(), isTrue, reason: '$filePath should exist');
        expect(file.readAsStringSync().isNotEmpty, isTrue, reason: '$filePath should not be empty');
      });
    });
  });
}

/// Mock implementation for createFolderStructure
void createFolderStructure(String folderName) {
  final pagesDir = Directory('lib/pages');
  if (!pagesDir.existsSync()) {
    pagesDir.createSync(recursive: true);
  }

  final baseDir = Directory('${pagesDir.path}/$folderName');
  if (!baseDir.existsSync()) {
    baseDir.createSync();
  }

  final subFoldersWithContent = {
    'view': '''
import 'package:flutter/material.dart';

class PlaceholderView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Placeholder();
}
''',
    'controller': '''
class PlaceholderController {}
''',
    'model': '''
class PlaceholderModel {}
''',
    'provider': '''
class PlaceholderProvider {}
''',
    'binding': '''
class PlaceholderBinding {}
'''
  };

  subFoldersWithContent.forEach((folder, content) {
    final dir = Directory('${baseDir.path}/$folder');
    dir.createSync();
    final file = File('${dir.path}/${folderName}_$folder.dart');
    file.writeAsStringSync(content);
  });
}
