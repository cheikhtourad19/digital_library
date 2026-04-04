import 'package:flutter/material.dart';

import '../../ui/pages/admin/admin_layout.dart';
import '../../ui/pages/client/client_layout.dart';
import '../../ui/pages/login_page.dart';
import '../../ui/pages/session_gate_page.dart';
import '../../ui/pages/signup_page.dart';

class AppRouter {
  static const String sessionGate = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String clientHome = '/client/home';
  static const String clientBooks = '/client/books';
  static const String clientFavorites = '/client/favorites';
  static const String clientProfile = '/client/profile';
  static const String adminHome = '/admin/home';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminBooks = '/admin/books';
  static const String adminUsers = '/admin/users';
  static const String adminSettings = '/admin/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case sessionGate:
        return MaterialPageRoute(
          builder: (_) => const SessionGatePage(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
          settings: settings,
        );
      case clientHome:
        return MaterialPageRoute(
          builder: (_) => const ClientLayout(initialIndex: 0),
          settings: settings,
        );
      case clientBooks:
        return MaterialPageRoute(
          builder: (_) => const ClientLayout(initialIndex: 1),
          settings: settings,
        );
      case clientFavorites:
        return MaterialPageRoute(
          builder: (_) => const ClientLayout(initialIndex: 2),
          settings: settings,
        );
      case clientProfile:
        return MaterialPageRoute(
          builder: (_) => const ClientLayout(initialIndex: 3),
          settings: settings,
        );
      case adminHome:
        return MaterialPageRoute(
          builder: (_) => const AdminLayout(initialIndex: 0),
          settings: settings,
        );
      case adminAnalytics:
        return MaterialPageRoute(
          builder: (_) => const AdminLayout(initialIndex: 1),
          settings: settings,
        );
      case adminBooks:
        return MaterialPageRoute(
          builder: (_) => const AdminLayout(initialIndex: 2),
          settings: settings,
        );
      case adminUsers:
        return MaterialPageRoute(
          builder: (_) => const AdminLayout(initialIndex: 3),
          settings: settings,
        );
      case adminSettings:
        return MaterialPageRoute(
          builder: (_) => const AdminLayout(initialIndex: 4),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SessionGatePage(),
          settings: settings,
        );
    }
  }
}
