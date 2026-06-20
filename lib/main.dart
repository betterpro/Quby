import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'services/stripe_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';

Future<void> _configureGoogleMaps() async {
  final platform = GoogleMapsFlutterPlatform.instance;
  if (platform is GoogleMapsFlutterAndroid) {
    platform.useAndroidViewSurface = true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureGoogleMaps();
  try {
    await SupabaseService.initialize();
    await StripeService.initialize();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SupabaseService.isSignedIn
        ? const MainShell()
        : const OnboardingScreen();
  }
}
