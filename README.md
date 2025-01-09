

## Features

- Automatically sets up a base folder structure for a Flutter project using the `Get` and `GetStorage` packages.
- Creates a custom folder structure for new pages, including `view`, `controller`, `model`, `provider`, and `binding` subfolders.
- Includes pre-written Dart files with boilerplate code for efficient development.
- Supports initial setup with automatic installation of required packages and updates to `main.dart`.

## Getting Started

1. Ensure you have Flutter installed on your system and set up correctly.
2. Add the `simple_getx_folder_create` package to your Flutter project or clone the repository.
3. Run the following command in your terminal to initialize the project structure:

   ```bash
   dart run simple_getx_folder_create
   ```

4. For additional page-specific folder structures, use the `-f` flag as described below.

## Usage

### Initial Setup

- Run the command to install the required dependencies (`Get` and `GetStorage`) and set up the base folder structure:

   ```bash
   dart run simple_getx_folder_create
   ```

- The setup will:
  - Create a `lib` folder structure with directories like `pages`, `network`, `utils`, and `widgets`.
  - Update the `main.dart` file with pre-configured boilerplate code.
  - Create a `splash` page as the default initial route.

### Add a New Page

- Use the `-f` flag to create a new page folder structure:

   ```bash
   dart run simple_getx_folder_create -f your_folder_name
   ```

- This will generate:
  - A folder named after your page inside the `lib/pages` directory.
  - Subfolders (`view`, `controller`, `model`, etc.) within the page folder.
  - Sample Dart files in each subfolder to help you get started.

### Example

To create a new page named `home`:

```bash
dart run simple_getx_folder_create -f home
```

This will generate:

```
lib/
└── pages/
    └── home/
        ├── view/
        │   └── home_page.dart
        ├── controller/
        │   └── home_controller.dart
        ├── model/
        │   └── home_model.dart
        ├── provider/
        │   └── home_provider.dart
        └── binding/
            └── home_binding.dart
```

## Additional Information

- After the initial setup, you may need to update the `api_service.dart` file with your API-related logic.
- Customize the generated files as per your project requirements.
- Contributions are welcome! Feel free to submit issues or pull requests.
