import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobymoney/features/ai_chat/presentation/ai_chat_screen.dart';
import 'package:mobymoney/features/analytics/presentation/analytics_screen.dart';
import 'package:mobymoney/features/authentication/presentation/login_screen.dart';
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

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
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
          final expense = state.extra as RecentExpenseItemModel;
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
