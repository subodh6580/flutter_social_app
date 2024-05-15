// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class ApplicationLocalizations {
//   Locale appLocale;
//   ApplicationLocalizations({required this.appLocale});
//
//   static const LocalizationsDelegate<ApplicationLocalizations> delegate =
//       _AppLocalizationsDelegate();
//   static ApplicationLocalizations of(BuildContext context) {
//     return Localizations.of<ApplicationLocalizations>(
//         context, ApplicationLocalizations)!;
//   }
//
//   static Map<String, dynamic>? _localizedStrings;
//
//   static Future<ApplicationLocalizations> load(Locale locale) async {
//     ApplicationLocalizations appTranslations = ApplicationLocalizations(appLocale: locale);
//
//     // Load JSON file from the "resources" folder
//     String jsonString =
//         await rootBundle.loadString('resources/${locale.languageCode}.json');
//     _localizedStrings = json.decode(jsonString);
//     return appTranslations;
//   }
//
//   // called from every widget which needs a localized text
//   String translate(String jsonKey) {
//     return _localizedStrings![jsonKey];
//   }
// }
//
// class _AppLocalizationsDelegate
//     extends LocalizationsDelegate<ApplicationLocalizations> {
//   // This delegate instance will never change (it doesn't even have fields!)
//   // It can provide a constant constructor.
//   const _AppLocalizationsDelegate();
//
//   @override
//   bool isSupported(Locale locale) {
//     // Include all of your supported language codes here
//     return ['en', 'ar'].contains(locale.languageCode);
//   }
//
//   @override
//   Future<ApplicationLocalizations> load(Locale locale) async {
//     // AppLocalizations class is where the JSON loading actually runs
//     return ApplicationLocalizations.load(locale);
//   }
//
//   @override
//   bool shouldReload(_AppLocalizationsDelegate old) => false;
// }
