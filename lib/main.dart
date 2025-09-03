import 'package:athletica/features/auth/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xbasxziyzplckxhrpltj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhiYXN4eml5enBsY2t4aHJwbHRqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5MTIwNjQsImV4cCI6MjA3MjQ4ODA2NH0.gS7I5UCABefVcru_YadvhjrG7N0fOiEsorPxZzokiHQ',
  );

  runApp(const AthleticaApp());
}

final supabase = Supabase.instance.client;


class AthleticaApp extends StatelessWidget {
  const AthleticaApp({super.key});

  @override
  Widget build(BuildContext context) {
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      print('Auth event: $event');
    });
    return MaterialApp(
      title: 'Athletica',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
      },
      home: AuthGate(),
    );
  }
}
