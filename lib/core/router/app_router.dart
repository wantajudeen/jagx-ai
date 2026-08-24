import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/email_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/set_password_screen.dart';
import '../../features/chat/presentation/screens/chat_home_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      final authRoutes = ['/email', '/otp', '/set-password'];
      final isOnAuth = authRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !isOnAuth && state.matchedLocation != '/') {
        return '/email';
      }

      if (isLoggedIn && isOnAuth) {
        return '/chat';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/email',
        builder: (context, state) => const EmailScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/set-password',
        builder: (context, state) => const SetPasswordScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatHomeScreen(),
      ),
    ],
  );
});
