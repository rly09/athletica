import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
