import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/logging/app_logger.dart';
import 'core/routing/app_router.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'features/common/presentation/offline_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime font fetching — fonts are bundled in the package.
  // This prevents network calls on first launch and works fully offline.
  GoogleFonts.config.allowRuntimeFetching = false;


  // Global Flutter error catching (prevents silent crashes)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.e(
      'Unhandled Flutter UI Error: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
      'FLUTTER_ERROR',
    );
  };

  // Global Async/Platform error catching
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.e(
      'Unhandled Platform/Async Error: $error',
      error,
      stack,
      'PLATFORM_ERROR',
    );
    return true; // handled
  };

  // Lock orientation to portrait for reliable layouts
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables (.env)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // If .env is missing in testing/CI, default fallbacks will be used
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Android: dark icons on light background
      statusBarIconBrightness: Brightness.dark,
      // iOS: Brightness.light = dark icons (counterintuitive naming)
      statusBarBrightness: Brightness.light,
      // Navigation bar (Android only)
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: MobyMoneyApp(),
    ),
  );
}

class MobyMoneyApp extends ConsumerWidget {
  const MobyMoneyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final isOffline = connectivity == ConnectivityStatus.isDisconnected;
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MobyMoney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        // Prevent high-DPI text scaling from breaking UI badges & horizontal rows
        final mediaQuery = MediaQuery.of(context);
        final clampedScale = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.25,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScale),
          child: Stack(
            children: [
              if (child != null) child,
              if (isOffline)
                Positioned.fill(
                  child: OfflineScreen(
                    onRetry: () async {
                      return await ref.read(connectivityProvider.notifier).checkConnection();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

