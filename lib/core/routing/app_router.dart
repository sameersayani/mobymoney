import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobymoney/features/ai_chat/presentation/ai_chat_screen.dart';
import 'package:mobymoney/features/analytics/presentation/analytics_screen.dart';
import 'package:mobymoney/features/authentication/presentation/login_screen.dart';
import 'package:mobymoney/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mobymoney/features/authentication/presentation/register_screen.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/expenses/presentation/all_expenses_screen.dart';
import 'package:mobymoney/features/expenses/presentation/expense_detail_screen.dart';
import 'package:mobymoney/features/expenses/presentation/expenses_screen.dart';
import 'package:mobymoney/features/home/presentation/home_screen.dart';
import 'package:mobymoney/features/settings/presentation/expense_types_screen.dart';
import 'package:mobymoney/features/settings/presentation/settings_screen.dart';
import 'package:mobymoney/features/splash/presentation/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class _RouterListenable extends ChangeNotifier {
  _RouterListenable(Ref ref) {
    ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerListenableProvider = Provider<_RouterListenable>((ref) {
  return _RouterListenable(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerListenableProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.asData?.value != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      // If user is not logged in and not on an auth route, force redirect to Login
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenses,
        name: 'expenses',
        builder: (context, state) => const ExpensesScreen(),
      ),
      GoRoute(
        path: AppRoutes.allExpenses,
        name: 'allExpenses',
        builder: (context, state) => const AllExpensesScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenseDetail,
        name: 'expenseDetail',
        builder: (context, state) {
          final expense = state.extra as RecentExpenseItemModel?;
          if (expense == null) {
            // Safe fallback: navigate back if extra is missing
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => context.go(AppRoutes.home),
            );
            return const SizedBox.shrink();
          }
          return ExpenseDetailScreen(expense: expense);
        },
      ),
      GoRoute(
        path: AppRoutes.analytics,
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        name: 'aiChat',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenseTypes,
        name: 'expenseTypes',
        builder: (context, state) => const ExpenseTypesScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image_outlined, size: 64, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Route: ${state.uri.toString()}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const expenses = '/expenses';
  static const allExpenses = '/all-expenses';
  static const expenseDetail = '/expense-detail';
  static const analytics = '/analytics';
  static const aiChat = '/ai-chat';
  static const settings = '/settings';
  static const expenseTypes = '/settings/expense-types';
}
