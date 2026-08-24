import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      context.go('/chat');
    } else {
      context.go('/email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'JagX',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
