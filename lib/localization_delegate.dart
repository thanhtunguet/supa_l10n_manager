import 'package:flutter/material.dart';

import 'localization.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Loads the localization for the current [locale].
  static Future<AppLocalizations> load(Locale locale,
      {String? fallbackLocale}) async {
    await Localization.load(locale.languageCode,
        fallbackLocale: fallbackLocale);
    return AppLocalizations(locale);
  }

  /// Retrieves the current [AppLocalizations] instance.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Returns the translated string for the given [key].
  String translate(String key, [Map<String, dynamic>? args]) {
    return Localization.translate(key, args);
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final String? fallbackLocale;

  const AppLocalizationsDelegate({this.fallbackLocale});

  @override
  bool isSupported(Locale locale) => true; // Or restrict to supported locales

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations.load(locale, fallbackLocale: fallbackLocale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
