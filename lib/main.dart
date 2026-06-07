import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.initialize();
  } catch (_) {
    // App works offline with seed data if Supabase is unreachable
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: const QubyApp(),
    ),
  );
}

class QubyApp extends StatelessWidget {
  const QubyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) => MaterialApp(
        title: 'Quby',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: state.isDark ? ThemeMode.dark : ThemeMode.light,
        home: const OnboardingScreen(),
      ),
    );
  }
}
