import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class S implements WidgetsLocalizations {
  const S();

  static late S current;

  static const GeneratedLocalizationsDelegate delegate =
    GeneratedLocalizationsDelegate();

  static S of(BuildContext context) => Localizations.of<S>(context, S)!;

  @override
  String get reorderItemToStart => "reorderItemToStart";
  
  @override
  String get reorderItemToEnd => "reorderItemToEnd";

  @override
  String get reorderItemUp => "reorderItemUp";

  @override
  String get reorderItemDown => "reorderItemDown";

  @override
  String get reorderItemLeft => "reorderItemLeft";

  @override
  String get reorderItemRight => "reorderItemRight";
      
  @override
  TextDirection get textDirection => TextDirection.ltr;
  
  String get create_wallet => """Create Wallet""";
  String get restore_wallet => """Restore Wallet""";
  String get your_seed => """Your Frankencoin-seed""";
  String get your_seed_disclaimer => """This is your unique and private seed and it is the only way to recover your wallet in case of loss or malfunction.""";
  String get welcome_frankecoin_wallet => """Welcome in the 
Frankencoin Wallet""";
  String get welcome_disclaimer => """By using Frankencoin Wallet you agree to our terms and conditions.""";
}

class $de extends S {
  const $de();
      
  @override
  TextDirection get textDirection => TextDirection.ltr;
  
  @override
  String get create_wallet => """Wallet erstellen""";
  @override
  String get restore_wallet => """Wallet wiederherstellen""";
  @override
  String get your_seed => """Dein Frankencoin-Seed""";
  @override
  String get your_seed_disclaimer => """Dies ist Ihr einzigartiger und privater Seed und der einzige Weg, um Ihre Wallet im Falle eines Verlusts oder einer Fehlfunktion wiederherzustellen.""";
  @override
  String get welcome_frankecoin_wallet => """Willkommen im 
Frankencoin Wallet""";
  @override
  String get welcome_disclaimer => """Durch die Nutzung von Frankencoin Wallet stimmen Sie unseren Nutzungsbedinungen zu.""";
}

class $en extends S {
  const $en();
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<S> {
  const GeneratedLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale("de", ""),
      Locale("en", ""),
    ];
  }

  LocaleListResolutionCallback listResolution({required Locale fallback, bool withCountry = true}) {
    return (List<Locale>? locales, Iterable<Locale> supported) {
      if (locales == null || locales.isEmpty) {
        return fallback ?? supported.first;
      } else {
        return _resolve(locales.first, fallback, supported, withCountry);
      }
    };
  }

  LocaleResolutionCallback resolution({required Locale fallback, bool withCountry = true}) {
    return (Locale? locale, Iterable<Locale> supported) {
      return _resolve(locale, fallback, supported, withCountry);
    };
  }

  @override
  Future<S> load(Locale locale) {
    final String lang = getLang(locale);
    if (lang != null) {
      switch (lang) {
        case "de":
          S.current = const $de();
          return SynchronousFuture<S>(S.current);
        case "en":
          S.current = const $en();
          return SynchronousFuture<S>(S.current);
        default:
      }
    }
    S.current = const S();
    return SynchronousFuture<S>(S.current);
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale, true);

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;

  Locale _resolve(Locale? locale, Locale fallback, Iterable<Locale> supported, bool withCountry) {
    if (locale == null || !_isSupported(locale, withCountry)) {
      return fallback ?? supported.first;
    }

    final Locale languageLocale = Locale(locale.languageCode, "");
    if (supported.contains(locale)) {
      return locale;
    } else if (supported.contains(languageLocale)) {
      return languageLocale;
    } else {
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    }
  }

  bool _isSupported(Locale locale, bool withCountry) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode != locale.languageCode) {
          continue;
        }
        if (supportedLocale.countryCode == locale.countryCode) {
          return true;
        }
        if (true != withCountry && (supportedLocale.countryCode == null || supportedLocale.countryCode!.isEmpty)) {
          return true;
        }
      }
    }
    return false;
  }
}

String getLang(Locale l) => l == null
  ? throw Exception('Incorrect local')
  : l.countryCode != null && l.countryCode!.isEmpty
    ? l.languageCode
    : l.toString();
