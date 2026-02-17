import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'core/router/restaurant_admin_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/supabase_constants.dart';
import 'core/di/injection_container.dart';
import 'core/utils/logger.dart';
import 'l10n/app_localizations.dart';
import 'core/localization/locale_cubit.dart';

void main() async {
  AppLogger.logInfo('=== Restaurant Admin App Starting ===');
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

    AppLogger.logInfo('Launching restaurant admin app...');
    runApp(const RestaurantAdminApp());
  } catch (e, stackTrace) {
    // Handle initialization errors
    AppLogger.logError(
      'Error initializing app',
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

class RestaurantAdminApp extends StatelessWidget {
  const RestaurantAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: InjectionContainer().getBlocProviders(),
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp.router(
            title: '${AppConstants.appName} - Restaurant Admin',
            theme: AppTheme.lightTheme,
            routerConfig: RestaurantAdminRouter.router,
            debugShowCheckedModeBanner: false,
            locale: localeState.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          );
        },
      ),
    );
  }
}
