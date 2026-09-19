import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'features/common/presentation/offline_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // If .env is missing in testing/CI, default fallbacks will be used
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
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
      title: 'Moby Money',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
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
        );
      },
    );
  }
}

