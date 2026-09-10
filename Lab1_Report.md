# Lab 1: Setting Up Flutter and Running Your First App

## Exercise 1 & 2
- Project created: `hello_flutter_lab1`
- Screenshots for `flutter doctor`, plugins, project structure, running app, and updated title need to be taken by the student.

## Exercise 3
- Customized UI in `lib/main.dart` with simple widgets (Scaffold, AppBar, Text, Column, Icon, ElevatedButton).

## Exercise 4 - Reflection Questions

**1. What is the purpose of the flutter doctor command?**
The `flutter doctor` command checks your system for the dependencies and tools required to build and run Flutter apps (e.g., Flutter SDK, Android Studio, connected devices). It reports on the status of the installation and provides instructions on how to resolve missing dependencies or configuration issues.

**2. What file acts as the entry point of a Flutter application?**
The `lib/main.dart` file acts as the entry point of a Flutter application. Specifically, the `main()` function inside this file is where execution starts.

**3. Explain the difference between Hot Reload and Hot Restart.**
- **Hot Reload** injects updated source code files into the running Dart Virtual Machine (VM). This updates the UI almost instantly without losing the app's current state.
- **Hot Restart** destroys the current app state and completely restarts the Flutter app with the new code, taking slightly longer than Hot Reload but resetting the state completely.

**4. How does runApp() build the widget tree?**
`runApp()` takes a given `Widget` and makes it the root of the widget tree. It inflates the given widget and attaches it to the screen, triggering the framework's build process for all its child widgets to render the UI on the device.

**5. Describe how Flutter’s architecture enables cross-platform development.**
Flutter uses its own rendering engine (Skia or Impeller) written in C++ to paint UI components directly on the screen canvas, rather than relying on native OEM widgets. Along with the Dart framework that abstracts platform differences, this allows a single codebase to run across iOS, Android, Web, and Desktop platforms with native-like performance and a consistent look and feel.
