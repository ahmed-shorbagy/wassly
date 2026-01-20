import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'core/di/injection_container.dart';
import 'core/utils/logger.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'features/articles/presentation/views/web_landing_page.dart';

void main() async {
  AppLogger.logInfo('=== Starting To Order Web App ===');
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    AppLogger.logInfo('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.logSuccess('Firebase initialized');

    // Initialize Supabase
    AppLogger.logInfo('Initializing Supabase...');
    await Supabase.initialize(
      url: SupabaseConstants.projectUrl,
      anonKey: SupabaseConstants.anonKey,
    );
    AppLogger.logSuccess('Supabase initialized');

    // Initialize dependency injection
    AppLogger.logInfo('Initializing dependency injection...');
    await InjectionContainer().init();
    AppLogger.logSuccess('Dependency injection initialized');

    AppLogger.logInfo('Launching web app...');
    runApp(const WasslyWebApp());
  } catch (e, stackTrace) {
    AppLogger.logError(
      'Error initializing web app',
      error: e,
      stackTrace: stackTrace,
    );
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error initializing app: $e'))),
      ),
    );
  }
}

class WasslyWebApp extends StatelessWidget {
  const WasslyWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: InjectionContainer().getWebBlocProviders(),
      child: MaterialApp(
        title: 'To Order',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const WebLandingPage(),
      ),
    );
  }
}
