import 'package:supa_l10n_manager/plural.dart';
import 'package:supa_l10n_manager/translator.dart';

/// Describes the translation keys for a single time unit
/// with pluralization forms.
class UnitKeySet {
  final String one;
  final String other;
  final String? zero;

  UnitKeySet({
    required this.one,
    required this.other,
    this.zero,
  });
}

/// Holds the translation key sets for all time units we support.
class TimeKeySets {
  final UnitKeySet years;
  final UnitKeySet months;
  final UnitKeySet days;
  final UnitKeySet hours;
  final UnitKeySet minutes;
  final UnitKeySet seconds;

  TimeKeySets({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });
}

String _formatWithKeys(UnitKeySet keys, int value) {
  if (value == 0 && keys.zero != null) {
    return translate(keys.zero!, {'value': value});
  }
  if (value == 1) {
    return translate(keys.one, {'value': value});
  }
  return translate(keys.other, {'value': value});
}

/// Formats a [Duration] into a localized time string using a callback-based
/// translate marker pattern.
///
/// The [callback] receives a `TranslateCallback` that simply echoes keys, so you
/// can construct and return the set of translation keys without triggering
/// translation at build-time. Translation occurs here with the resolved value(s).
///
/// Examples of resulting strings (depending on your provided keys):
/// - "{value} year(s)"
/// - "{value} month(s)"
/// - "{value} day(s)"
/// - "{value} hour(s)"
/// - "{h} hour(s) {m} minute(s)" (when [combineHoursAndMinutes] is true)
/// - "{value} minute(s)"
/// - "{value} second(s)"
String translateTime(
  Duration duration,
  TimeKeySets Function(TranslateCallback) callback, {
  bool combineHoursAndMinutes = false,
}) {
  // Build key sets using a pure marker translate callback.
  final keySets = callback((key) => key);

  final totalDays = duration.inDays;
  final totalHours = duration.inHours;
  final totalMinutes = duration.inMinutes;
  final totalSeconds = duration.inSeconds;

  // Determine the dominant unit to display, with an optional hour+minute combo.
  if (totalDays >= 365) {
    final years = totalDays ~/ 365;
    return _formatWithKeys(keySets.years, years);
  }
  if (totalDays >= 30) {
    final months = totalDays ~/ 30;
    return _formatWithKeys(keySets.months, months);
  }
  if (totalDays >= 1) {
    return _formatWithKeys(keySets.days, totalDays);
  }

  final hours = totalHours; // since days == 0 here, this is < 24
  final minutesRemainder = totalMinutes % 60;

  if (hours >= 1) {
    if (combineHoursAndMinutes && minutesRemainder > 0) {
      final hoursStr = _formatWithKeys(keySets.hours, hours);
      final minutesStr = _formatWithKeys(keySets.minutes, minutesRemainder);
      return "$hoursStr $minutesStr";
    }
    return _formatWithKeys(keySets.hours, hours);
  }

  final minutes = totalMinutes; // < 60 here
  if (minutes >= 1) {
    return _formatWithKeys(keySets.minutes, minutes);
  }

  final seconds = totalSeconds; // < 60 here
  return _formatWithKeys(keySets.seconds, seconds);
}
