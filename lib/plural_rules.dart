import 'plural_category.dart';

/// Handles pluralization rules for different languages according to CLDR standards
class PluralRules {
  /// Determines the appropriate plural category for a given value and locale
  static PluralCategory getPluralCategory(int value, String? locale) {
    if (locale == null) {
      return _getEnglishPluralCategory(value);
    }

    final languageCode = locale.split('_').first.toLowerCase();

    switch (languageCode) {
      // Languages with 2 forms (like English)
      case 'en':
      case 'de':
      case 'es':
      case 'fr':
      case 'it':
      case 'pt':
      case 'nl':
      case 'sv':
      case 'da':
      case 'no':
      case 'fi':
      case 'tr':
      case 'he':
      case 'ja':
      case 'ko':
      case 'zh':
      case 'th':
      case 'vi':
        return _getEnglishPluralCategory(value);

      // Languages with 3 forms (like Russian)
      case 'ru':
      case 'uk':
      case 'be':
      case 'sr':
      case 'hr':
      case 'bs':
      case 'mk':
      case 'bg':
        return _getSlavicPluralCategory(value);

      // Languages with 4 forms (like Polish)
      case 'pl':
      case 'cs':
      case 'sk':
        return _getPolishPluralCategory(value);

      // Languages with 6 forms (like Arabic)
      case 'ar':
        return _getArabicPluralCategory(value);

      // Languages with special rules
      case 'ga': // Irish
        return _getIrishPluralCategory(value);

      case 'cy': // Welsh
        return _getWelshPluralCategory(value);

      case 'mt': // Maltese
        return _getMaltesePluralCategory(value);

      default:
        return _getEnglishPluralCategory(value);
    }
  }

  /// English-like pluralization (2 forms: one, other)
  /// Note: English doesn't have a separate "zero" form, 0 uses "other"
  static PluralCategory _getEnglishPluralCategory(int value) {
    if (value == 1) {
      return PluralCategory.one;
    }
    return PluralCategory.other;
  }

  /// Slavic pluralization (Russian, Ukrainian, etc.) - 3 forms
  static PluralCategory _getSlavicPluralCategory(int value) {
    if (value == 1) {
      return PluralCategory.one;
    }

    // Check if the number ends in 1 (but not 11, 111, etc.)
    final lastDigit = value % 10;
    final lastTwoDigits = value % 100;

    if (lastDigit == 1 && lastTwoDigits != 11) {
      return PluralCategory.one;
    }

    // Check if the number ends in 2, 3, or 4 (but not 12, 13, 14)
    if (lastDigit >= 2 &&
        lastDigit <= 4 &&
        (lastTwoDigits < 10 || lastTwoDigits > 20)) {
      return PluralCategory.few;
    }

    return PluralCategory.other;
  }

  /// Polish pluralization - 4 forms
  static PluralCategory _getPolishPluralCategory(int value) {
    if (value == 1) {
      return PluralCategory.one;
    }

    // Check if the number ends in 1 (but not 11, 111, etc.)
    final lastDigit = value % 10;
    final lastTwoDigits = value % 100;

    if (lastDigit == 1 && lastTwoDigits != 11) {
      return PluralCategory.one;
    }

    // Check if the number ends in 2, 3, or 4 (but not 12, 13, 14)
    if (lastDigit >= 2 &&
        lastDigit <= 4 &&
        (lastTwoDigits < 10 || lastTwoDigits > 20)) {
      return PluralCategory.few;
    }

    // Check if the number ends in 0 or 5-9
    if (lastDigit == 0 || (lastDigit >= 5 && lastDigit <= 9)) {
      return PluralCategory.many;
    }

    return PluralCategory.other;
  }

  /// Arabic pluralization - 6 forms
  static PluralCategory _getArabicPluralCategory(int value) {
    if (value == 0) {
      return PluralCategory.zero;
    }
    if (value == 1) {
      return PluralCategory.one;
    }
    if (value == 2) {
      return PluralCategory.two;
    }

    // Check for few (3-10)
    if (value >= 3 && value <= 10) {
      return PluralCategory.few;
    }

    // Check for many (11-99)
    if (value >= 11 && value <= 99) {
      return PluralCategory.many;
    }

    return PluralCategory.other;
  }

  /// Irish pluralization - 5 forms
  static PluralCategory _getIrishPluralCategory(int value) {
    if (value == 1) {
      return PluralCategory.one;
    }
    if (value == 2) {
      return PluralCategory.two;
    }
    if (value >= 3 && value <= 6) {
      return PluralCategory.few;
    }
    if (value >= 7 && value <= 10) {
      return PluralCategory.many;
    }
    return PluralCategory.other;
  }

  /// Welsh pluralization - 6 forms
  static PluralCategory _getWelshPluralCategory(int value) {
    if (value == 0) {
      return PluralCategory.zero;
    }
    if (value == 1) {
      return PluralCategory.one;
    }
    if (value == 2) {
      return PluralCategory.two;
    }
    if (value == 3) {
      return PluralCategory.few;
    }
    if (value == 6) {
      return PluralCategory.many;
    }
    return PluralCategory.other;
  }

  /// Maltese pluralization - 4 forms
  static PluralCategory _getMaltesePluralCategory(int value) {
    if (value == 1) {
      return PluralCategory.one;
    }
    if (value == 0 || (value >= 2 && value <= 10)) {
      return PluralCategory.few;
    }
    if (value >= 11 && value <= 19) {
      return PluralCategory.many;
    }
    return PluralCategory.other;
  }

  /// Gets all supported language codes
  static List<String> getSupportedLanguages() {
    return [
      'en',
      'de',
      'es',
      'fr',
      'it',
      'pt',
      'nl',
      'sv',
      'da',
      'no',
      'fi',
      'tr',
      'he',
      'ja',
      'ko',
      'zh',
      'th',
      'vi',
      'ru',
      'uk',
      'be',
      'sr',
      'hr',
      'bs',
      'mk',
      'bg',
      'pl',
      'cs',
      'sk',
      'ar',
      'ga',
      'cy',
      'mt'
    ];
  }

  /// Gets the number of plural forms for a given language
  static int getPluralFormCount(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ar':
        return 6;
      case 'ga':
      case 'cy':
        return 5;
      case 'pl':
      case 'cs':
      case 'sk':
      case 'mt':
        return 4;
      case 'ru':
      case 'uk':
      case 'be':
      case 'sr':
      case 'hr':
      case 'bs':
      case 'mk':
      case 'bg':
        return 3;
      default:
        return 2;
    }
  }
}
