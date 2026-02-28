# Copilot instructions for `simple_getx_folder_create`

## Rule precedence for Dart/Flutter code
- For all `*.dart` files, follow `.github/dart-n-flutter.instructions.md` as the default coding standard.
- Apply Effective Dart conventions (naming, import ordering, formatting, async/await-first style) unless existing repo code intentionally differs.
- Keep architecture suggestions from that file **within this repo’s chosen stack**: this package scaffolds GetX apps, so do not replace GetX patterns with Provider/go_router unless explicitly requested.
- When updating generator output, enforce those style rules in template sources (`lib/file_with_content.dart`, `lib/sub_folder_with_context.dart`) so generated projects inherit them.

## What this repository is
- This is a **Dart CLI scaffolder package** (not a full Flutter app source tree).
- Main entrypoint for users is `bin/simple_getx_folder_create.dart`; a near-identical library entry also exists at `lib/simple_getx_folder_create.dart`.
- The tool creates/updates files in a target Flutter project (`lib/pages`, `lib/network`, `lib/utils`, `lib/widgets`, and `lib/main.dart`) and drops `.setup_completed` to make base setup one-time.

## Core architecture and data flow
- CLI parsing uses `args` (`-f` / `--folder`) in `bin/simple_getx_folder_create.dart`.
- `createBaseFolderStructure()` writes a fixed set of files from the template map in `lib/file_with_content.dart`.
- `createPageFolderStructure(folderName)` builds `lib/pages/<folderName>/{view,controller,model,provider,binding}` using templates in `lib/sub_folder_with_context.dart`.
- `updateMainDart()` overwrites `lib/main.dart` with a GetX + GetStorage bootstrapped app shell.
- First run (no `.setup_completed`): adds `get_storage` and `get`, runs `flutter pub get`, scaffolds base files, then scaffolds `splash`.
- Later run with `-f name`: adds only the page module structure.

## Template conventions to follow
- Treat `lib/file_with_content.dart` and `lib/sub_folder_with_context.dart` as the source of truth for generated content.
- Generated page naming convention:
  - `view/<name>_page.dart`
  - `controller/<name>_controller.dart`
  - `model/<name>_model.dart`
  - `provider/<name>_provider.dart`
  - `binding/<name>_binding.dart`
- Generated app wiring pattern uses GetX dependency injection and route list in `utils/routes.dart`.
- Network layer template is `ApiService extends GetConnect` + `ApiException` mapping (`lib/network/api_service.dart`, `lib/network/api_exception.dart` in generated projects).

## Developer workflows in this repo
- Install deps: `dart pub get`
- Run scaffolder from this package: `dart run simple_getx_folder_create`
- Create page module: `dart run simple_getx_folder_create -f home`
- Run tests: `dart test`
- Analyze: `dart analyze`

## Testing and examples
- Primary package test is file-system oriented in `test/simple_getx_folder_create_test.dart`.
- `example/` contains a generated Flutter app snapshot that shows expected output structure and GetX wiring (`example/lib/main.dart`, `example/lib/pages/splash/...`).

## Important repo-specific notes for agents
- Prefer editing `bin/simple_getx_folder_create.dart` and mirroring critical entrypoint logic to `lib/simple_getx_folder_create.dart` to keep behavior consistent.
- Keep generated code changes centralized in template maps rather than patching generated outputs in `example/` unless explicitly asked.
- Preserve existing folder/file names and GetX conventions; downstream users rely on these exact scaffold paths.
- `_runCommand` is async and currently fire-and-forget; if changing setup sequencing, ensure command ordering remains deterministic.
- `SubFoldersWithContentClass` uses static template state; be careful when changing `folderName`-dependent template generation.
