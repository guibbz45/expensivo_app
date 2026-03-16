import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homepage.dart';
import 'providers/expense_provider.dart';
import 'models/expense_model.dart';
import 'screens/add_edit_expense_screen.dart';
import 'screens/expense_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..loadExpenses(limit: 10),
      child: MaterialApp(
        title: 'Expensivo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const HomePage(),
      ),
    );
  }
}


abstract class AppTheme {
  static const _primary = Color(0xFF1A3A52);
  static const _secondary = Color(0xFF0D1F2D);
  static const _surface = Color(0xFF121212);
  static const _card = Color(0xFF1E1E1E);
  static const _error = Color(0xFFCF6679);
  static const _accent = Color(0xFF4A90E2);

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.dark,
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
      error: _error,
    ),
    scaffoldBackgroundColor: _surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: _secondary,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    cardTheme: const CardThemeData(
      color: _card,
      elevation: 2,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _card,
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(color: _accent, width: 2),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
  );

  static OutlineInputBorder _border({
    Color color = _primary,
    double width = 1,
  }) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
}


abstract class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/add':
        return _buildRoute(
          settings,
          (context) => AddEditExpenseScreen(
            onSave: (expense) =>
                _provider(context).addExpense(expense),
          ),
        );

      case '/edit':
        final expense = settings.arguments as Expense?;
        return _buildRoute(
          settings,
          (context) => AddEditExpenseScreen(
            expense: expense,
            onSave: (updated) {
              if (expense != null) {
                _provider(context).updateExpense(expense.id, updated);
              }
            },
          ),
        );

      case '/detail':
        final expense = settings.arguments as Expense;
        return _buildRoute(
          settings,
          (_) => ExpenseDetailScreen(expense: expense),
        );

      default:
        return _buildRoute(
          settings,
          (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    RouteSettings settings,
    Widget Function(BuildContext) builder,
  ) =>
      MaterialPageRoute(settings: settings, builder: builder);

  static ExpenseProvider _provider(BuildContext context) =>
      Provider.of<ExpenseProvider>(context, listen: false);
}