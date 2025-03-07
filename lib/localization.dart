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
      final jsonString =
          await rootBundle.loadString('assets/i18n/$locale.json');
      final Map<String, dynamic> flatMap = json.decode(jsonString);
      _translations = _convertFlatMapToNested(flatMap);
      _cache[locale] = _translations;
    } catch (e) {
      log.fine('Error loading localization for locale $locale: $e');
      _translations = {};
      _cache[locale] = _translations;
    }
  }

  /// Converts a flat JSON map with dot-separated keys into a nested map.
  static Map<String, dynamic> _convertFlatMapToNested(
      Map<String, dynamic> flatMap) {
    final Map<String, dynamic> nestedMap = {};

    for (var entry in flatMap.entries) {
      final List<String> keys = entry.key.split('.')
        ..sort(
          (a, b) => a.compareTo(b),
        );
      dynamic current = nestedMap;

      for (int i = 0; i < keys.length; i++) {
        final key = keys[i];

        if (i == keys.length - 1) {
          // Set the final value
          current[key] = entry.value;
        } else {
          // If key doesn't exist, initialize as a map
          current[key] ??= {};
          current = current[key];
        }
      }
    }
    return nestedMap;
  }

  /// Returns the translation for the given [key].
  /// Optionally passes [args] to replace placeholders in the translation.
  static String translate(String key, [Map<String, dynamic>? args]) {
    // Keys are assumed to be structured as namespace.subnamespace.key.
    final keys = key.split('.');
    String? translation = _getNestedTranslation(_translations, keys);
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
      Map<String, dynamic> map, List<String> keys) {
    dynamic current = map;
    for (var key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        break;
      }
    }
    return current is String ? current : null;
  }
}
