import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_gui/services/app_language.dart';

import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Locale sysLocale = basicLocaleListResolution(
      [WidgetsBinding.instance.platformDispatcher.locale],
      AppLocalizations.supportedLocales);
  debugPrint('sysLocale: ${sysLocale.languageCode}');

  /// Initialize Hive Database
  await Hive.initFlutter();

  /// Open the database
  await Hive.openBox('appLocalDb');

  /// Set the default language for the app and make it persistent
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('language_code', sysLocale.languageCode);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myLocale = ref.watch(appLanguageProvider);
    debugPrint('Got myLocale $myLocale');
    final appLocale = ref.watch(appLocalizationsProvider);
    debugPrint('Got appLocale ${appLocale.localeName}');

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MyHomePage(title: 'Test GUI'),
      locale: myLocale,
    );
  }
}

Color kLorenzBlue = const Color.fromRGBO(0, 62, 129, 1.0);
TextStyle kBtnTextStyle = const TextStyle(fontSize: 19.0, color: Colors.white);

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _counter = 0;

  static List<String> menuItems = AppLocalizations.supportedLocales
      .map((Locale loc) => loc.languageCode)
      .toList();

  final List<PopupMenuItem<String>> _popUpMenuItems = menuItems
      .map(
        (String value) => PopupMenuItem<String>(
          value: value,
          child: Text(value),
        ),
      )
      .toList();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _pickDate() async {
    //debugPrint()
    final lang = ref.read(appLanguageProvider);
    final loc = ref.read(appLocalizationsProvider);
    DateTime dateNow = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(dateNow.year - 1),
      lastDate: DateTime(dateNow.year + 2),
      helpText: loc.newDueDate,
      errorFormatText: 'Enter a valid date',
      errorInvalidText: 'Enter date in valid range',
      locale: lang,
      keyboardType: const TextInputType.numberWithOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.read(appLocalizationsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLorenzBlue,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.translate,
              color: Colors.white,
            ),
            onSelected: (String newValue) {
              debugPrint(newValue);
              ref
                  .read(appLanguageProvider.notifier)
                  .setAppLanguage(Locale(newValue));
            },
            itemBuilder: (BuildContext context) => _popUpMenuItems,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(loc.textMessage),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kLorenzBlue,
                foregroundColor: Colors.white,
                elevation: 6.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              onPressed: () {
                debugPrint(
                    'Selected language is ${ref.watch(appLanguageProvider)}');
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'TEST',
                  style: kBtnTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kLorenzBlue,
        foregroundColor: Colors.white,
        tooltip: 'Increment',
        onPressed: () {
          _incrementCounter();

          /// This shows localization of system dialogs
          _pickDate();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
