import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'config/flavor_config.dart';
import 'firebase_options.dart';
import 'core/router/customer_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'core/di/injection_container.dart';
import 'core/utils/logger.dart';
import 'l10n/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'shared/widgets/back_button_handler.dart';

void main() async {
  // Initialize flavor configuration
  FlavorConfig.initialize(flavor: Flavor.customer);

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

    AppLogger.logInfo('Launching Customer app...');
    runApp(const ToOrderCustomerApp());
    FlutterNativeSplash.remove();
  } catch (e, stackTrace) {
    AppLogger.logError(
      'Error initializing Customer app',
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

class ToOrderCustomerApp extends StatelessWidget {
  const ToOrderCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: InjectionContainer().getBlocProviders(),
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return ScreenUtilInit(
            designSize: const Size(375, 812), // iPhone X design size
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return BackButtonHandler(
                child: MaterialApp.router(
                  title: FlavorConfig.instance.appName,
                  theme: AppTheme.lightTheme,
                  routerConfig: CustomerRouter.router,
                  debugShowCheckedModeBanner: false,
                  locale: localeState.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
