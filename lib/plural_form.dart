import 'plural_category.dart';
import 'plural_rules.dart';

/// Represents a plural form with support for all CLDR pluralization categories
class PluralForm {
  /// The translation for exactly 1 item (singular)
  final String one;

  /// The translation for all other cases (default plural)
  final String other;

  /// The translation for 0 items (optional)
  final String? zero;

  /// The translation for exactly 2 items (optional, used in some languages)
  final String? two;

  /// The translation for few items (optional, used in Slavic languages)
  final String? few;

  /// The translation for many items (optional, used in some languages)
  final String? many;

  /// The numeric value to determine pluralization
  final int value;

  /// The locale for which this plural form is intended
  final String? locale;

  PluralForm({
    required this.one,
    required this.other,
    required this.value,
    this.zero,
    this.two,
    this.few,
    this.many,
    this.locale,
  });

  /// Gets the translation string for the given plural category
  String? getTranslationForCategory(PluralCategory category) {
    switch (category) {
      case PluralCategory.zero:
        return zero;
      case PluralCategory.one:
        return one;
      case PluralCategory.two:
        return two;
      case PluralCategory.few:
        return few;
      case PluralCategory.many:
        return many;
      case PluralCategory.other:
        return other;
    }
  }

  /// Gets the appropriate translation string based on the value and locale
  String getAppropriateTranslation() {
    final category = PluralRules.getPluralCategory(value, locale);
    return getTranslationForCategory(category) ?? other;
  }
}
