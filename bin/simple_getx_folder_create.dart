// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';
import 'package:simple_getx_folder_create/simple_getx_folder_create.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('folder', abbr: 'f', help: 'Name of the page folder to create');
  final argResults = parser.parse(arguments);

  final setupFile = File('.setup_completed');

  if (!setupFile.existsSync()) {
    // Install get and get_storage packages
    _runCommand('flutter pub add get_storage');
    _runCommand('flutter pub add get');
    _runCommand('flutter pub get');
    // Run the base setup only once
    createBaseFolderStructure();
    updateMainDart();
    print('Initial setup completed.');
  }

  if (argResults.wasParsed('folder')) {
    final folderName = argResults['folder'] as String?;
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
      print('You need to configure api_service.dart with your API base URL.');
    } else {
      print('No folder name provided. Use the -f flag to specify a page name.');
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
