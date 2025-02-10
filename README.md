# supa_l10n_manager

A Flutter localization package with a CLI tool to manage and load translations efficiently.

## Features

✅ **Namespace-Based Key Organization** - Keeps translation files modular  
✅ **Automatic Translation Key Extraction** - Finds missing keys in your Dart code  
✅ **CLI Tool for JSON Merging & Key Extraction** - Simplifies localization management  
✅ **Async & Cached Translation Loading** - Ensures performance  
✅ **Fallback Locale Support** - Prevents missing translation issues  

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  supa_l10n_manager:
    git:
      url: https://github.com/thanhtunguet/supa_l10n_manager.git
```

Then run:

```bash
flutter pub get
```

---

## File Structure

Translations are stored in **namespace-based JSON files** inside `assets/i18n/<locale>/`.

```
assets/i18n/
  en/
    user.json
    product.json
  vi/
    user.json
    product.json
```

Each file contains a **flat JSON structure**:

**`assets/i18n/en/user.json`**
```json
{
  "login.username": "Username",
  "login.password": "Password"
}
```

**Automatically converted into this nested map:**
```dart
{
  "user": {
    "login": {
      "username": "Username",
      "password": "Password"
    }
  }
}
```

---

## Usage in a Flutter App

### **1. Load Localization Data**
Before using translations, load the desired locale:

```dart
import 'package:supa_l10n_manager/localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Localization.load('en');
  runApp(MyApp());
}
```

---

### **2. Retrieve Translations**
Use the `translate` function in your app:

```dart
import 'package:supa_l10n_manager/translator.dart';

String usernameLabel = translate('user.login.username'); 
print(usernameLabel); // Output: "Username"
```

You can also use dynamic values:

```dart
print(translate('dashboard.welcome', {'name': 'John'}));
// Output: "Welcome, John!"
```

---

## Flutter Integration

To integrate with Flutter’s localization system, use the provided delegate:

```dart
import 'package:flutter/material.dart';
import 'package:supa_l10n_manager/localization_delegate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(fallbackLocale: 'en'),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],
      home: Scaffold(
        appBar: AppBar(title: const Text('Localization Example')),
        body: Center(
          child: Text(translate('user.login.username')),
        ),
      ),
    );
  }
}
```

---

## CLI Tool

The package provides a CLI tool to **merge JSON files** and **extract missing keys**.

### **1. Merge JSON Files**
Merges all `namespace.json` files into a single file per locale:

```bash
dart run bin/cli.dart merge
```

After merging:

```
assets/i18n/
  en.json  // Merged file
  vi.json  // Merged file
```

---

### **2. Extract Missing Keys**
Scans Dart code for `translate('key')` usages and updates namespace files.

```bash
dart run bin/cli.dart extract --locale en --source lib
```

#### **If the following keys are found in Dart code:**
```dart
translate('user.login.username');
translate('user.login.password');
```

#### **Then `assets/i18n/en/user.json` is created/updated:**
```json
{
  "login.username": "Username",
  "login.password": "Password"
}
```

- If `user.json` does not exist, it is **automatically created**.
- If a key is missing, it is **added with an empty string**.

---

## Example JSON Files After Extraction

**`assets/i18n/en/user.json` (Updated)**
```json
{
  "login.username": "Username",
  "login.password": "Password",
  "profile.email": ""
}
```

The missing key `"profile.email"` was **automatically added**.

---

## Performance Considerations

✅ Loads **only necessary locale JSON files** at runtime  
✅ **Caches translations** for efficient lookups  
✅ Uses **async file loading** for better performance  

---

## Contributing

1. Fork the repository  
2. Make changes  
3. Submit a pull request  

---

## License

MIT License. Free to use and modify. 🚀
