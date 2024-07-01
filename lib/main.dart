import 'package:firebase_chat_app/pages/login_page.dart';
import 'package:firebase_chat_app/services/auth_service.dart';
import 'package:firebase_chat_app/services/navigation_service.dart';
import 'package:firebase_chat_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_chat_app/utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  await setup();
  runApp( MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await registerServices();
}

class MyApp extends StatelessWidget {
  final GetIt _getIt =GetIt.instance;

  late NavigationService _navigationService;
  late AuthService _authService;

  MyApp({super.key}){
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
}

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        //textTheme: GoogleFonts.pacificoTextTheme(),
      ),
      initialRoute: _authService.user != null ? "/home" : "/login",
      routes: _navigationService.routes,
    );
  }
}

