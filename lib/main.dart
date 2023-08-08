// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oho_pos_v3/splash_screen/splash_screen.dart';
import 'package:provider/provider.dart';
import 'CounterProvider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/url_strategy.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  usePathUrlStrategy();
  runApp(
    Phoenix(
      child: const MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CounterProvider(),
      child: MaterialApp(
        title: 'OHO ORDERING',
        theme: ThemeData(
          // colorScheme: ColorScheme.fromSwatch().copyWith(
          //   primary: const Color(0xff4fc3f7),
          // ),
          fontFamily: 'Kanit',
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('th', 'TH'), // Thai
        ],
        builder: EasyLoading.init(),
      ),
    );
  }
}
