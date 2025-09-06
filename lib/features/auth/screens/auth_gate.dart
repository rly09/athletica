import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Session? _session;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _recoverSession();

    // 🔹 Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
      });
    });
  }

  Future<void> _recoverSession() async {
    final currentSession = Supabase.instance.client.auth.currentSession;
    setState(() {
      _session = currentSession;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_session != null) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
