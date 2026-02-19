import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'data/services/api_service.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'providers/favourite_provider.dart';
import 'providers/message_provider.dart';
import 'providers/visit_provider.dart';
import 'providers/alert_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('fr_FR', null);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const HomeFinderApp());
}

class HomeFinderApp extends StatelessWidget {
  const HomeFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),

        ChangeNotifierProvider(
          create: (_) => AuthProvider(api)..init(),
        ),

        ChangeNotifierProvider(
          create: (_) => PropertyProvider(api),
        ),

        ChangeNotifierProxyProvider<PropertyProvider, FavouriteProvider>(
          create: (ctx) => FavouriteProvider(api, ctx.read<PropertyProvider>()),
          update: (_, propProv, prev) =>
          prev ?? FavouriteProvider(api, propProv),
        ),

        ChangeNotifierProvider(
          create: (_) => MessageProvider(api),
        ),

        ChangeNotifierProvider(
          create: (_) => VisitProvider(api),
        ),

        ChangeNotifierProvider(
          create: (_) => AlertProvider(api),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // ── Auth gate ──────────────────────────────────────────────────────
        // Consumer rebuilds whenever AuthProvider notifies.
        // This is the ONLY place navigation between Login ↔ Home happens.
        // Login and Register screens must NOT do their own navigation on success.
        home: Consumer<AuthProvider>(
          builder: (_, auth, __) {
            if (auth.loading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return auth.authenticated ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}