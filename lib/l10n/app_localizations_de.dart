import 'app_localizations.dart';

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get helloWorld => 'Hallo Welt!';

  @override
  String get textMessage => 'Sie haben den Knopf schon so oft gedrückt:';

  @override
  String get newDueDate => 'Wählen Sie ein neuer Stichtag';
}
