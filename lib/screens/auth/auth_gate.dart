import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../main_screen.dart';
import 'get_started_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (auth.startupError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(auth.startupError!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: auth.restoreSession,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return auth.user == null ? const GetStartedScreen() : const MainScreen();
  }
}
