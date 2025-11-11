import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/flavor_config.dart';
import 'firebase_options.dart';
import 'core/router/customer_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'core/utils/logger.dart';

void main() async {
  // Initialize flavor configuration
  FlavorConfig.initialize(flavor: Flavor.customer);
  
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

    AppLogger.logInfo('Launching Customer app...');
    runApp(const WasslyCustomerApp());
  } catch (e, stackTrace) {
    AppLogger.logError(
      'Error initializing Customer app',
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

class WasslyCustomerApp extends StatelessWidget {
  const WasslyCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: InjectionContainer().getBlocProviders(),
      child: MaterialApp.router(
        title: FlavorConfig.instance.appName,
        theme: AppTheme.lightTheme,
        routerConfig: CustomerRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

