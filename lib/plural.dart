import 'package:supa_l10n_manager/plural_form.dart';
import 'package:supa_l10n_manager/translator.dart';

typedef TranslateCallback = String Function(String);

String _internalTranslate(String key) {
  return key;
}

/// Handles pluralization with support for all CLDR pluralization categories
///
/// This function supports complex pluralization rules for various languages including:
/// - English-like languages (2 forms: one, other)
/// - Slavic languages like Russian (3 forms: one, few, other)
/// - Polish (4 forms: one, few, many, other)
/// - Arabic (6 forms: zero, one, two, few, many, other)
/// - And many more languages
///
/// Example usage:
/// ```dart
/// String message = plural((translate) {
///   return PluralForm(
///     one: translate('item.one'),
///     other: translate('item.other'),
///     few: translate('item.few'), // Optional for Slavic languages
///     many: translate('item.many'), // Optional for Polish/Arabic
///     two: translate('item.two'), // Optional for Arabic
///     zero: translate('item.zero'), // Optional for Arabic
///     value: count,
///     locale: 'ru', // Optional, uses current locale if not provided
///   );
/// });
/// ```
String plural(PluralForm Function(TranslateCallback) callback) {
  final pluralForm = callback(_internalTranslate);

  // Get the appropriate translation based on the value and locale
  final translation = pluralForm.getAppropriateTranslation();

  // Translate the selected string and substitute the value
  return translate(translation, {
    'value': pluralForm.value,
  });
}

/// Legacy function for backward compatibility
///
/// This function maintains the old behavior for existing code.
/// For new code, use the main `plural()` function which supports
/// all CLDR pluralization categories.
@Deprecated(
    'Use the main plural() function instead for better language support')
String pluralSimple(PluralForm Function(TranslateCallback) callback) {
  final pluralForm = callback(_internalTranslate);
  if (pluralForm.value == 1) {
    return translate(pluralForm.one, {
      'value': pluralForm.value,
    });
  }
  if (pluralForm.value == 0) {
    if (pluralForm.zero != null) {
      return translate(pluralForm.zero!, {
        'value': pluralForm.value,
      });
    }
  }
  return translate(pluralForm.other, {
    'value': pluralForm.value,
  });
}
