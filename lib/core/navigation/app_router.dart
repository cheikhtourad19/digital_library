import 'package:digital_library/models/user_model.dart';
import 'package:digital_library/ui/pages/admin/admin_user_detail_page.dart';
import 'package:flutter/material.dart';

import '../../ui/pages/admin/admin_layout.dart';
import '../../ui/pages/client/client_layout.dart';
import '../../ui/pages/login_page.dart';
import '../../ui/pages/session_gate_page.dart';
import '../../ui/pages/signup_page.dart';

class AppRouter {
  // ── Layer 1 — Auth ────────────────────────────────────────────
  static const String sessionGate = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  // ── Layer 2 — Shells (single entry per role) ──────────────────
  static const String client = '/client';
  static const String admin = '/admin';

  // ── Layer 3 — Detail pages (push on top of shell) ─────────────
  // static const String bookDetail = '/book/detail';
  // static const String authorDetail = '/author/detail';
  static const String adminUserDetailPage = '/admin/user/detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case sessionGate:
        return _route(const SessionGatePage(), settings);

      case login:
        return _route(const LoginPage(), settings);

      case signup:
        return _route(const SignUpPage(), settings);

      case client:
        return _route(const ClientLayout(), settings);

      case admin:
        return _route(const AdminLayout(), settings);

      // Layer 3 detail pages go here when needed:
      // case bookDetail:
      //   final book = settings.arguments as BookModel;
      //   return _route(BookDetailPage(book: book), settings);

      case adminUserDetailPage:
        final user = settings.arguments as User;
        return _route(AdminUserDetailPage(user: user), settings);

      default:
        return _route(const SessionGatePage(), settings);
    }
  }

  static MaterialPageRoute _route(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
