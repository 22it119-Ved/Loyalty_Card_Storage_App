// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:loyalty_card_app/firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_card_app/services/auth_service.dart';
import 'package:loyalty_card_app/services/card_service.dart';
import 'package:loyalty_card_app/services/notification_service.dart';
import 'package:loyalty_card_app/services/sync_service.dart';
import 'package:loyalty_card_app/screens/splash_screen.dart';
import 'package:loyalty_card_app/screens/login_screen.dart';
import 'package:loyalty_card_app/screens/home_screen.dart';
import 'package:loyalty_card_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  await NotificationService().initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        return ChangeNotifierProvider(
          create: (_) => CardService(),
          child: MaterialApp(
            title: 'Everyday Rewards',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            home: const LoginScreen(),
          ),
        );
      },
    );
  }
}
