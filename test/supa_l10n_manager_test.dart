import 'package:flutter_test/flutter_test.dart';
import 'package:supa_l10n_manager/plural.dart';
import 'package:supa_l10n_manager/supa_l10n_manager.dart';

String testTranslate(int value) {
  return plural(
    (translate) {
      return PluralForm(
        one: translate('test.value.one'),
        other: translate('test.value.other'),
        zero: translate('test.value.zero'),
        value: value,
      );
    },
  );
}

void main() {
  test('translate', () {
    final one = testTranslate(1);
    final other = testTranslate(2);
    final zero = testTranslate(0);
    expect(one, 'test.value.one');
    expect(other, 'test.value.other');
    expect(zero, 'test.value.zero');
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
