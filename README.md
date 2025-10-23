# supa_l10n_manager

A Flutter localization package with a CLI tool to manage and load translations efficiently.

## Features

✅ **Namespace-Based Key Organization** - Keeps translation files modular  
✅ **Automatic Translation Key Extraction** - Finds missing keys in your Dart code  
✅ **CLI Tool for JSON Merging, Key Extraction & Reordering** - Simplifies localization management  
✅ **Async & Cached Translation Loading** - Ensures performance  
✅ **Fallback Locale Support** - Prevents missing translation issues  
✅ **Advanced Pluralization Support** - CLDR-compliant rules for 30+ languages including Russian, Polish, Arabic  

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

### **3. Advanced Pluralization Support**

The `plural` function supports **CLDR-compliant pluralization rules** for 30+ languages, including complex cases like Russian, Polish, and Arabic.

#### **Basic Usage (English-like languages)**
```dart
import 'package:supa_l10n_manager/plural.dart';

final result = plural((t) {
  return PluralForm(
    one: t('items.one'),      // e.g. "{value} item"
    other: t('items.other'),  // e.g. "{value} items"
    zero: t('items.zero'),    // optional, e.g. "No items"
    value: 2,
    locale: 'en', // Optional, uses current locale if not provided
  );
});
```

#### **Russian Pluralization (3 forms)**
```dart
final result = plural((t) {
  return PluralForm(
    one: t('items.one'),      // 1, 21, 31, 101, etc.
    few: t('items.few'),      // 2, 3, 4, 22, 23, 24, etc.
    other: t('items.other'),  // 0, 5-20, 25-30, etc.
    value: 21,
    locale: 'ru',
  );
});
// Result: "items.one" (because 21 ends in 1, not 11)
```

#### **Polish Pluralization (4 forms)**
```dart
final result = plural((t) {
  return PluralForm(
    one: t('items.one'),      // 1, 21, 31, etc.
    few: t('items.few'),      // 2, 3, 4, 22, 23, 24, etc.
    many: t('items.many'),    // 0, 5-19, 25-29, etc.
    other: t('items.other'),  // 20-24, 30-34, etc.
    value: 5,
    locale: 'pl',
  );
});
// Result: "items.many" (because 5 ends in 5-9)
```

#### **Arabic Pluralization (6 forms)**
```dart
final result = plural((t) {
  return PluralForm(
    zero: t('items.zero'),   // 0
    one: t('items.one'),      // 1
    two: t('items.two'),      // 2
    few: t('items.few'),       // 3-10
    many: t('items.many'),    // 11-99
    other: t('items.other'),  // 100+
    value: 3,
    locale: 'ar',
  );
});
// Result: "items.few" (because 3 is in range 3-10)
```

#### **Supported Languages**
- **English-like (2 forms)**: English, German, Spanish, French, Italian, Portuguese, Dutch, Swedish, Danish, Norwegian, Finnish, Turkish, Hebrew, Japanese, Korean, Chinese, Thai, Vietnamese
- **Slavic (3 forms)**: Russian, Ukrainian, Belarusian, Serbian, Croatian, Bosnian, Macedonian, Bulgarian
- **Polish (4 forms)**: Polish, Czech, Slovak
- **Arabic (6 forms)**: Arabic
- **Special cases**: Irish (5 forms), Welsh (6 forms), Maltese (4 forms)

#### **Fallback Behavior**
If a specific plural form isn't provided, the system falls back to the `other` form:

```dart
final result = plural((t) {
  return PluralForm(
    one: t('items.one'),
    other: t('items.other'),
    // No 'few' provided for Russian
    value: 2,
    locale: 'ru',
  );
});
// Result: "items.other" (falls back because 'few' is missing)
```

Your translations should include the `{value}` placeholder if you want to display the number.

#### **Advanced Pluralization API**
For more control over pluralization, you can use the `PluralRules` class directly:

```dart
import 'package:supa_l10n_manager/plural_rules.dart';
import 'package:supa_l10n_manager/plural_category.dart';

// Get the plural category for a specific value and locale
final category = PluralRules.getPluralCategory(21, 'ru');
print(category); // PluralCategory.one

// Get supported languages
final languages = PluralRules.getSupportedLanguages();
print(languages); // ['en', 'de', 'es', 'fr', 'ru', 'pl', 'ar', ...]

// Get the number of plural forms for a language
final formCount = PluralRules.getPluralFormCount('ru');
print(formCount); // 3 (one, few, other)
```

---

### **4. Time duration formatting (translateTime)**

`translateTime` converts a `Duration` into a localized string. It uses a callback-based translate marker similar to `plural`, so your source contains only keys until runtime translation occurs.

Supports: years, months, days, hours, minutes, seconds, and an hours+minutes combined variant.

```dart
import 'package:supa_l10n_manager/time.dart';

final text = translateTime(
  Duration(hours: 2, minutes: 5),
  (t) => TimeKeySets(
    years: UnitKeySet(one: t('time.year.one'), other: t('time.year.other'), zero: t('time.year.zero')),
    months: UnitKeySet(one: t('time.month.one'), other: t('time.month.other'), zero: t('time.month.zero')),
    days: UnitKeySet(one: t('time.day.one'), other: t('time.day.other'), zero: t('time.day.zero')),
    hours: UnitKeySet(one: t('time.hour.one'), other: t('time.hour.other'), zero: t('time.hour.zero')),
    minutes: UnitKeySet(one: t('time.minute.one'), other: t('time.minute.other'), zero: t('time.minute.zero')),
    seconds: UnitKeySet(one: t('time.second.one'), other: t('time.second.other'), zero: t('time.second.zero')),
  ),
  combineHoursAndMinutes: true, // produces e.g. "2 hours 5 minutes"
);
```

Behavior summary:
- If `duration >= 365 days`: uses year keys
- Else if `>= 30 days`: uses month keys
- Else if `>= 1 day`: uses day keys
- Else if `>= 1 hour`: uses hour keys; if `combineHoursAndMinutes` and minutes remainder > 0, concatenates hours and minutes
- Else if `>= 1 minute`: uses minute keys
- Else: uses second keys (including zero when provided)

---

## Migration from Previous Versions

If you're upgrading from a previous version, the pluralization API is **backward compatible**. Your existing code will continue to work:

```dart
// Old code (still works)
final result = plural((t) {
  return PluralForm(
    one: t('items.one'),
    other: t('items.other'),
    zero: t('items.zero'),
    value: 2,
  );
});
```

However, for better language support, consider updating to the new API:

```dart
// New code (recommended)
final result = plural((t) {
  return PluralForm(
    one: t('items.one'),
    other: t('items.other'),
    zero: t('items.zero'),
    value: 2,
    locale: 'en', // Explicit locale for better control
  );
});
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

The package provides a CLI tool to **merge JSON files**, **extract missing keys**, and **reorder translation keys**.

### **1. Merge JSON Files**
Merges all `namespace.json` files into a single file per locale:

```bash
dart run bin/supa_l10n_manager.dart merge
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
dart run bin/supa_l10n_manager.dart extract --locale en --source lib
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

### **3. Reorder Translation Keys**
Alphabetically sorts all keys in translation files for better organization and easier version control:

```bash
dart run bin/supa_l10n_manager.dart reorder
```

This command:
- Works on both merged locale files (e.g., `en.json`) and individual namespace files
- Processes all JSON files in the `assets/i18n` directory tree
- Keeps translation files organized with consistent key ordering
- Makes comparing and merging translations easier

Before reordering:
```json
{
  "login.password": "Password",
  "profile.email": "Email",
  "login.username": "Username"
}
```

After reordering:
```json
{
  "login.password": "Password",
  "login.username": "Username",
  "profile.email": "Email"
}
```

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
✅ **Efficient pluralization rules** with O(1) lookup complexity  
✅ **Minimal memory footprint** for pluralization engine  

---

## Contributing

1. Fork the repository  
2. Make changes  
3. Submit a pull request  

---

## License

MIT License. Free to use and modify. 🚀
