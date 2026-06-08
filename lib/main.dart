import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.initialize();
  } catch (_) {
    // App works offline with seed data if Supabase is unreachable
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
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
        home: const _StartupRouter(),
      ),
    );
  }
}

// Routes to MainShell if already signed in, otherwise OnboardingScreen
class _StartupRouter extends StatefulWidget {
  const _StartupRouter();

  @override
  State<_StartupRouter> createState() => _StartupRouterState();
}

class _StartupRouterState extends State<_StartupRouter> {
  @override
  void initState() {
    super.initState();
    if (SupabaseService.isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppState>().initialize();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SupabaseService.isSignedIn
        ? const MainShell()
        : const OnboardingScreen();
  }
}
