import 'dart:io';

import 'package:erp_oshxona/View/Auth/pincode_view.dart';
import 'package:erp_oshxona/Widget/restart_widget.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/Library/Themes/flutter.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    Controller.directory = await getApplicationSupportDirectory();
  } else {
    Controller.directory = await getApplicationDocumentsDirectory();
  }
  if (!await Controller.directory.exists()) {
    await Controller.directory.create(recursive: true);
  }
  Hive.init(Controller.directory.path);
  await Sozlash.init();

  runApp(const RestartWidget(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final Widget viewKorsat;

    // PIN code bor bo'lsa - tersin
    if (Sozlash.pinCodeBormi) {
      viewKorsat = AuthPinView(type: AuthPinViewType.auth);
    } else {
      viewKorsat = getView();
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      //systemNavigationBarColor: Color.fromRGBO(255, 255, 255, 1),
      //systemNavigationBarIconBrightness: Brightness.dark,
      //systemNavigationBarColor: Color.fromRGBO(245, 247, 251, 1),
      statusBarColor: Colors.blue,
      statusBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
    ));
    return MaterialApp(
      title: 'ERP Oshxona by INWARE',
      theme: flutterTheme,
      home: viewKorsat,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
    );
  }
}
