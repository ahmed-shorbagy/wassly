import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'config/flavor_config.dart';
import 'firebase_options.dart';
import 'core/router/partner_router.dart';
import 'core/theme/partner_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'core/di/injection_container.dart';
import 'core/utils/logger.dart';
import 'l10n/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'shared/widgets/back_button_handler.dart';

void main() async {
  // Initialize flavor configuration
  FlavorConfig.initialize(flavor: Flavor.partner);

  AppLogger.logInfo('=== Starting ${FlavorConfig.instance.appName} ===');
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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

    // Initialize Notifications
    AppLogger.logInfo('Initializing Notifications...');
    final notificationService = InjectionContainer().notificationService;
    await notificationService.init();

    // Save Token if user is logged in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await notificationService.saveTokenToDatabase(currentUser.uid, 'partner');
    }

    AppLogger.logInfo('Launching Partner app...');
    runApp(const ToOrderPartnerApp());
    FlutterNativeSplash.remove();
  } catch (e, stackTrace) {
    AppLogger.logError(
      'Error initializing Partner app',
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

class ToOrderPartnerApp extends StatelessWidget {
  const ToOrderPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: InjectionContainer().getBlocProviders(),
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return BackButtonHandler(
            child: MaterialApp.router(
              title: FlavorConfig.instance.appName,
              theme: PartnerTheme.lightTheme,
              routerConfig: PartnerRouter.router,
              debugShowCheckedModeBanner: false,
              locale: localeState.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
            ),
          );
        },
      ),
    );
  }
}
