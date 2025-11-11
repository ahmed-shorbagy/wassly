import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/flavor_config.dart';
import 'firebase_options.dart';
import 'core/router/admin_router.dart';
import 'core/theme/admin_theme.dart';
import 'core/di/injection_container.dart';
import 'core/utils/logger.dart';

void main() async {
  // Initialize flavor configuration
  FlavorConfig.initialize(flavor: Flavor.admin);
  
  AppLogger.logInfo('=== Starting ${FlavorConfig.instance.appName} ===');
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    AppLogger.logInfo('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.logSuccess('Firebase initialized');

    // Initialize dependency injection
    AppLogger.logInfo('Initializing dependency injection...');
    await InjectionContainer().init();
    AppLogger.logSuccess('Dependency injection initialized');

    AppLogger.logInfo('Launching Admin app...');
    runApp(const WasslyAdminApp());
  } catch (e, stackTrace) {
    AppLogger.logError(
      'Error initializing Admin app',
      error: e,
      stackTrace: stackTrace,
    );
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
  }
}

class WasslyAdminApp extends StatelessWidget {
  const WasslyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: InjectionContainer().getBlocProviders(),
      child: MaterialApp.router(
        title: FlavorConfig.instance.appName,
        theme: AdminTheme.lightTheme,
        routerConfig: AdminRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

