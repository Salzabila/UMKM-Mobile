import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_umkm/service/keranjang_provider.dart';
import 'package:aplikasi_umkm/screens/onboarding_screen.dart';
import 'package:aplikasi_umkm/screens/login.dart';
import 'package:aplikasi_umkm/screens/main_navigation.dart';
import 'package:aplikasi_umkm/bloc/auth/auth_bloc.dart';
import 'package:aplikasi_umkm/bloc/auth/auth_event.dart';
import 'package:aplikasi_umkm/Repository/auth_repository.dart';
import 'package:intl/date_symbol_data_local.dart';

const pelindoBlue = Color(0xFF0077C9);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => KeranjangProvider()),
        BlocProvider(
          create: (ctx) => AuthBloc(authRepository: AuthRepository())
            ..add(const AuthCheckRequested()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, bool>> _getInitialRouteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final isLoggedIn = prefs.getString('token') != null;

    return {
      'seenOnboarding': hasSeenOnboarding,
      'isLoggedIn': isLoggedIn,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi UMKM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: pelindoBlue,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: pelindoBlue,
          secondary: Colors.blueAccent,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: pelindoBlue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: pelindoBlue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: FutureBuilder<Map<String, bool>>(
        future: _getInitialRouteStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            final bool hasSeenOnboarding = snapshot.data!['seenOnboarding']!;
            final bool isLoggedIn = snapshot.data!['isLoggedIn']!;
            if (hasSeenOnboarding) {
              return isLoggedIn
                  ? const MainNavigationScreen()
                  : const LoginScreen();
            } else {
              return const OnboardingScreen();
            }
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
