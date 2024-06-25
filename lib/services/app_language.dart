import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Get Locale from system settings
Locale systemLocale = basicLocaleListResolution(
    [WidgetsBinding.instance.platformDispatcher.locale],
    AppLocalizations.supportedLocales);

final appLanguageProvider =
    NotifierProvider<AppLanguage, Locale>(AppLanguage.new);

/// underlying Notifier
class AppLanguage extends Notifier<Locale> {
  @override
  Locale build() {
    state = systemLocale;
    return state;
  }

  void setAppLanguage(Locale loc) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (state == loc) {
      /// Update prefs in case it is null
      await prefs.setString('language_code', systemLocale.languageCode);
      return;
    }

    /// update shared preferences
    try {
      await prefs.setString('language_code', loc.languageCode);
      state = loc;
    } catch (e) {
      debugPrint(e.toString());

      /// fallback to English
      await prefs.setString('language_code', 'en');
      state = const Locale('en');
    }
  }

  void toggleAppLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Locale? newLocale;
    switch (prefs.getString('language_code')) {
      case 'de':
        debugPrint('DE-> EN');
        newLocale = const Locale('en');
        break;
      case 'en':
        debugPrint('EN-> DE');
        newLocale = const Locale('de');
        break;
      default:
        debugPrint('Language not supported');
    }

    /// fallback to English
    setAppLanguage((newLocale ?? const Locale('en')));
  }

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      setAppLanguage(systemLocale);
    } else {
      /// Update the state
      state = Locale(prefs.getString('language_code')!);
    }
    debugPrint("APP language is ${state.languageCode}");
    return Null;
  }
}

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  /// Check for changes triggered by the user button
  final Locale myAppLang = ref.watch(appLanguageProvider);
  ref.state = lookupAppLocalizations(myAppLang);

  /// Detect changes on system settings
  final observer = _LocaleObserver((locales) {
    debugPrint("appLocalizationProvider: LOCALE is changed from Settings");

    /// detected a system language change -> switch language as the system
    /// changing the notifier will trigger the rebuild of the provider
    ref.read(appLanguageProvider.notifier).setAppLanguage(
        basicLocaleListResolution(
            [WidgetsBinding.instance.platformDispatcher.locale],
            AppLocalizations.supportedLocales));
  });

  final binding = WidgetsBinding.instance;
  binding.addObserver(observer);
  ref.onDispose(() => binding.removeObserver(observer));

  return ref.state;
});

/// observer used to notify the caller when the locale changes (from system)
class _LocaleObserver extends WidgetsBindingObserver {
  _LocaleObserver(this._didChangeLocales);
  final void Function(List<Locale>? locales) _didChangeLocales;

  @override
  void didChangeLocales(List<Locale>? locales) {
    /// This is not triggered when the MaterialApp parameter "locale" is changed!
    debugPrint("didChangeLocales");
    _didChangeLocales(locales);
  }
}
