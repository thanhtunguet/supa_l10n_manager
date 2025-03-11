import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';

class Localization {
  static final Map<String, Map<String, dynamic>> _cache = {};
  static Map<String, dynamic> _translations = {};
  static String? _currentLocale;
  static String? _fallbackLocale;

  static String get currentLocale => _currentLocale ?? '';

  /// Loads translations asynchronously for the given [locale].
  /// Optionally provide a [fallbackLocale].
  static Future<void> load(String locale, {String? fallbackLocale}) async {
    Logger.root.level = Level.ALL; // defaults to Level.INFO
    Logger.root.onRecord.listen((record) {
      ///
    });

    final log = Logger('SupaLocalizationManager');

    _currentLocale = locale;
    _fallbackLocale = fallbackLocale;
    if (_cache.containsKey(locale)) {
      _translations = _cache[locale]!;
      return;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/i18n/$locale.json',
      );
      final Map<String, dynamic> flatMap = json.decode(jsonString);
      _translations = flatMap;
      _cache[locale] = _translations = flatMap;
    } catch (e) {
      log.fine('Error loading localization for locale $locale: $e');
      _translations = {};
      _cache[locale] = _translations;
    }
  }

  /// Returns the translation for the given [key].
  /// Optionally passes [args] to replace placeholders in the translation.
  static String translate(String key, [Map<String, dynamic>? args]) {
    // Keys are assumed to be structured as namespace.subnamespace.key.
    String? translation = _getNestedTranslation(_translations, key);
    if (translation == null && _fallbackLocale != null) {
      translation = key;
    }
    if (translation == null) {
      return key;
    }
    if (args != null) {
      args.forEach((placeholder, value) {
        translation =
            translation!.replaceAll('{$placeholder}', value.toString());
      });
    }
    return translation!;
  }

  /// Walks the nested map using the list of [keys].
  static String? _getNestedTranslation(
    Map<String, dynamic> map,
    String key,
  ) {
    if (map.containsKey(key)) {
      final translation = map[key];
      return (translation is String && translation.isNotEmpty)
          ? translation
          : key;
    }

    return key;
  }
}
