import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_umkm/service/keranjang_provider.dart';
import 'package:aplikasi_umkm/screens/onboarding_screen.dart';
import 'package:aplikasi_umkm/screens/login.dart';
import 'package:aplikasi_umkm/screens/main_navigation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aplikasi_umkm/models/barang.dart';
import 'package:aplikasi_umkm/models/pelanggan.dart';
import 'package:aplikasi_umkm/models/biaya_operasional.dart';
import 'package:aplikasi_umkm/models/return_barang.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import untuk API
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import BLoC & Repository
import 'package:aplikasi_umkm/bloc/auth/auth_bloc.dart';
import 'package:aplikasi_umkm/data/repositories/auth_repository.dart';

// Import Core
import 'package:aplikasi_umkm/core/network/api_client.dart';

const pelindoBlue = Color(0xFF0077C9);

// Dependency Injection Setup
final getIt = GetIt.instance;

Future<void> setupInjection() async {
  try {
    // Core - Register ApiClient & FlutterSecureStorage
    getIt.registerLazySingleton(() => ApiClient());
    getIt.registerLazySingleton(() => FlutterSecureStorage());
    
    // Repositories
    getIt.registerLazySingleton(() => AuthRepository(
      getIt<ApiClient>(),
      getIt<FlutterSecureStorage>(),
    ));
    
    print('✅ Dependency Injection setup berhasil');
  } catch (e) {
    print('⚠️ DI setup error: $e');
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup Hive (Local Storage)
  await Hive.initFlutter();
  await initializeDateFormatting('id_ID');
  Hive.registerAdapter(BarangAdapter());
  Hive.registerAdapter(PelangganAdapter());
  Hive.registerAdapter(BiayaOperasionalAdapter());
  Hive.registerAdapter(ReturnBarangAdapter());

  await Hive.openBox<Barang>('barangBox');
  await Hive.openBox<Pelanggan>('pelangganBox');
  await Hive.openBox<BiayaOperasional>('biayaBox');
  await Hive.openBox<ReturnBarang>('returnBox');

  // Setup Dependency Injection untuk API
  try {
    await setupInjection();
  } catch (e) {
    print('❌ Setup DI gagal: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        // Provider untuk Keranjang (Existing - Local State)
        ChangeNotifierProvider(
          create: (ctx) => KeranjangProvider(),
        ),
        // BLoC untuk Auth API (New - API State)
        BlocProvider(
          create: (ctx) => AuthBloc(getIt<AuthRepository>()),
          lazy: false,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: FutureBuilder<Map<String, bool>>(
        future: _getInitialRouteStatus(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Check routing
          if (snapshot.hasData) {
            final bool hasSeenOnboarding = snapshot.data!['seenOnboarding']!;
            final bool isLoggedIn = snapshot.data!['isLoggedIn']!;

            if (hasSeenOnboarding) {
              // Sudah lihat onboarding
              return isLoggedIn 
                  ? const MainNavigationScreen() 
                  : const LoginScreen();
            } else {
              // Belum lihat onboarding
              return const OnboardingScreen();
            }
          }

          // Fallback ke login
          return const LoginScreen();
        },
      ),
    );
  }
}