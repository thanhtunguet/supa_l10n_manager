import 'package:flutter_test/flutter_test.dart';
import 'package:supa_l10n_manager/supa_l10n_manager.dart';

String testTranslate(int value) {
  return plural(
    (translate) {
      return PluralForm(
        one: translate('test.value.one'),
        other: translate('test.value.other'),
        zero: translate('test.value.zero'),
        value: value,
        locale: 'en', // Explicitly set English locale
      );
    },
  );
}

void main() {
  group('Pluralization Tests', () {
    test('basic pluralization (English-like)', () {
      final one = testTranslate(1);
      final other = testTranslate(2);
      final zero = testTranslate(0);
      expect(one, 'test.value.one');
      expect(other, 'test.value.other');
      expect(
          zero, 'test.value.other'); // English doesn't have separate zero form
    });

    test('Russian pluralization (3 forms)', () {
      String russianTranslate(int value) {
        return plural(
          (translate) {
            return PluralForm(
              one: translate('item.one'),
              other: translate('item.other'),
              few: translate('item.few'),
              value: value,
              locale: 'ru',
            );
          },
        );
      }

      expect(russianTranslate(1), 'item.one'); // один
      expect(russianTranslate(2), 'item.few'); // два
      expect(russianTranslate(3), 'item.few'); // три
      expect(russianTranslate(4), 'item.few'); // четыре
      expect(russianTranslate(5), 'item.other'); // пять
      expect(russianTranslate(21), 'item.one'); // двадцать один
      expect(russianTranslate(22), 'item.few'); // двадцать два
      expect(russianTranslate(25), 'item.other'); // двадцать пять
    });

    test('Polish pluralization (4 forms)', () {
      String polishTranslate(int value) {
        return plural(
          (translate) {
            return PluralForm(
              one: translate('item.one'),
              other: translate('item.other'),
              few: translate('item.few'),
              many: translate('item.many'),
              value: value,
              locale: 'pl',
            );
          },
        );
      }

      expect(polishTranslate(1), 'item.one'); // jeden
      expect(polishTranslate(2), 'item.few'); // dwa
      expect(polishTranslate(3), 'item.few'); // trzy
      expect(polishTranslate(4), 'item.few'); // cztery
      expect(polishTranslate(5), 'item.many'); // pięć
      expect(polishTranslate(10), 'item.many'); // dziesięć
      expect(polishTranslate(11), 'item.other'); // jedenaście
      expect(polishTranslate(22), 'item.few'); // dwadzieścia dwa
    });

    test('Arabic pluralization (6 forms)', () {
      String arabicTranslate(int value) {
        return plural(
          (translate) {
            return PluralForm(
              zero: translate('item.zero'),
              one: translate('item.one'),
              two: translate('item.two'),
              few: translate('item.few'),
              many: translate('item.many'),
              other: translate('item.other'),
              value: value,
              locale: 'ar',
            );
          },
        );
      }

      expect(arabicTranslate(0), 'item.zero'); // صفر
      expect(arabicTranslate(1), 'item.one'); // واحد
      expect(arabicTranslate(2), 'item.two'); // اثنان
      expect(arabicTranslate(3), 'item.few'); // ثلاثة
      expect(arabicTranslate(10), 'item.few'); // عشرة
      expect(arabicTranslate(11), 'item.many'); // أحد عشر
      expect(arabicTranslate(99), 'item.many'); // تسعة وتسعون
      expect(arabicTranslate(100), 'item.other'); // مائة
    });

    test('fallback to other when specific form is not provided', () {
      String fallbackTranslate(int value) {
        return plural(
          (translate) {
            return PluralForm(
              one: translate('item.one'),
              other: translate('item.other'),
              // No few, many, etc. provided
              value: value,
              locale: 'ru', // Russian needs few form
            );
          },
        );
      }

      expect(fallbackTranslate(1), 'item.one');
      expect(fallbackTranslate(2), 'item.other'); // Falls back to other
      expect(fallbackTranslate(5), 'item.other');
    });
  });

  group('PluralRules Tests', () {
    test('English pluralization rules', () {
      expect(PluralRules.getPluralCategory(0, 'en'), PluralCategory.other);
      expect(PluralRules.getPluralCategory(1, 'en'), PluralCategory.one);
      expect(PluralRules.getPluralCategory(2, 'en'), PluralCategory.other);
      expect(PluralRules.getPluralCategory(100, 'en'), PluralCategory.other);
    });

    test('Russian pluralization rules', () {
      expect(PluralRules.getPluralCategory(1, 'ru'), PluralCategory.one);
      expect(PluralRules.getPluralCategory(2, 'ru'), PluralCategory.few);
      expect(PluralRules.getPluralCategory(3, 'ru'), PluralCategory.few);
      expect(PluralRules.getPluralCategory(4, 'ru'), PluralCategory.few);
      expect(PluralRules.getPluralCategory(5, 'ru'), PluralCategory.other);
      expect(PluralRules.getPluralCategory(21, 'ru'), PluralCategory.one);
      expect(PluralRules.getPluralCategory(22, 'ru'), PluralCategory.few);
      expect(PluralRules.getPluralCategory(25, 'ru'), PluralCategory.other);
    });

    test('Polish pluralization rules', () {
      expect(PluralRules.getPluralCategory(1, 'pl'), PluralCategory.one);
      expect(PluralRules.getPluralCategory(2, 'pl'), PluralCategory.few);
      expect(PluralRules.getPluralCategory(3, 'pl'), PluralCategory.few);
      expect(PluralRules.getPluralCategory(4, 'pl'), PluralCategory.few);
      expect(PluralRules.getPluralCategory(5, 'pl'), PluralCategory.many);
      expect(PluralRules.getPluralCategory(10, 'pl'), PluralCategory.many);
      expect(PluralRules.getPluralCategory(11, 'pl'), PluralCategory.other);
      expect(PluralRules.getPluralCategory(22, 'pl'), PluralCategory.few);
    });

    test('Arabic pluralization rules', () {
      expect(PluralRules.getPluralCategory(0, 'ar'), PluralCategory.zero);
      expect(PluralRules.getPluralCategory(1, 'ar'), PluralCategory.one);
      expect(PluralRules.getPluralCategory(2, 'ar'), PluralCategory.two);
      expect(PluralRules.getPluralCategory(3, 'ar'), PluralCategory.few);
      expect(PluralRules.getPluralCategory(10, 'ar'), PluralCategory.few);
      expect(PluralRules.getPluralCategory(11, 'ar'), PluralCategory.many);
      expect(PluralRules.getPluralCategory(99, 'ar'), PluralCategory.many);
      expect(PluralRules.getPluralCategory(100, 'ar'), PluralCategory.other);
    });

    test('supported languages', () {
      final supportedLanguages = PluralRules.getSupportedLanguages();
      expect(supportedLanguages, contains('en'));
      expect(supportedLanguages, contains('ru'));
      expect(supportedLanguages, contains('pl'));
      expect(supportedLanguages, contains('ar'));
      expect(supportedLanguages, contains('de'));
      expect(supportedLanguages, contains('fr'));
    });

    test('plural form counts', () {
      expect(PluralRules.getPluralFormCount('en'), 2);
      expect(PluralRules.getPluralFormCount('ru'), 3);
      expect(PluralRules.getPluralFormCount('pl'), 4);
      expect(PluralRules.getPluralFormCount('ar'), 6);
    });
  });

  group('time', () {
    TimeKeySets keys(TranslateCallback t) => TimeKeySets(
          years: UnitKeySet(
            one: t('time.year.one'),
            other: t('time.year.other'),
            zero: t('time.year.zero'),
          ),
          months: UnitKeySet(
            one: t('time.month.one'),
            other: t('time.month.other'),
            zero: t('time.month.zero'),
          ),
          days: UnitKeySet(
            one: t('time.day.one'),
            other: t('time.day.other'),
            zero: t('time.day.zero'),
          ),
          hours: UnitKeySet(
            one: t('time.hour.one'),
            other: t('time.hour.other'),
            zero: t('time.hour.zero'),
          ),
          minutes: UnitKeySet(
            one: t('time.minute.one'),
            other: t('time.minute.other'),
            zero: t('time.minute.zero'),
          ),
          seconds: UnitKeySet(
            one: t('time.second.one'),
            other: t('time.second.other'),
            zero: t('time.second.zero'),
          ),
        );

    test('years', () {
      final d1 = Duration(days: 365);
      final d2 = Duration(days: 800);
      final s1 = translateTime(d1, keys);
      final s2 = translateTime(d2, keys);
      expect(s1, 'time.year.one');
      expect(s2, 'time.year.other');
    });

    test('months', () {
      final d1 = Duration(days: 30);
      final d2 = Duration(days: 65);
      final s1 = translateTime(d1, keys);
      final s2 = translateTime(d2, keys);
      expect(s1, 'time.month.one');
      expect(s2, 'time.month.other');
    });

    test('days', () {
      final d1 = Duration(days: 1);
      final d2 = Duration(days: 2);
      final s1 = translateTime(d1, keys);
      final s2 = translateTime(d2, keys);
      expect(s1, 'time.day.one');
      expect(s2, 'time.day.other');
    });

    test('hours', () {
      final d1 = Duration(hours: 1);
      final d2 = Duration(hours: 3);
      final s1 = translateTime(d1, keys);
      final s2 = translateTime(d2, keys);
      expect(s1, 'time.hour.one');
      expect(s2, 'time.hour.other');
    });

    test('hours and minutes combined', () {
      final d = Duration(hours: 2, minutes: 5);
      final s = translateTime(d, keys, combineHoursAndMinutes: true);
      expect(s, 'time.hour.other time.minute.other');
    });

    test('hours without minutes when not combined', () {
      final d = Duration(hours: 2, minutes: 5);
      final s = translateTime(d, keys, combineHoursAndMinutes: false);
      expect(s, 'time.hour.other');
    });

    test('minutes', () {
      final d1 = Duration(minutes: 1);
      final d2 = Duration(minutes: 10);
      final s1 = translateTime(d1, keys);
      final s2 = translateTime(d2, keys);
      expect(s1, 'time.minute.one');
      expect(s2, 'time.minute.other');
    });

    test('seconds including zero', () {
      final d0 = Duration(seconds: 0);
      final d1 = Duration(seconds: 1);
      final d2 = Duration(seconds: 5);
      final s0 = translateTime(d0, keys);
      final s1 = translateTime(d1, keys);
      final s2 = translateTime(d2, keys);
      expect(s0, 'time.second.zero');
      expect(s1, 'time.second.one');
      expect(s2, 'time.second.other');
    });
  });
}
