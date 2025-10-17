import 'package:supa_l10n_manager/plural_form.dart';
import 'package:supa_l10n_manager/translator.dart';

typedef TranslateCallback = String Function(String);

String _internalTranslate(String key) {
  return key;
}

String plural(PluralForm Function(TranslateCallback) callback) {
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
