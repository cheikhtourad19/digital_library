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
  /*
      declari pageat lou5rayn lehna  w 3mlnahom push on top of shell pages 3shan yeb2a feh navigation independent 3lehom
       haka yweli 3ndna 3 niveaux - auth (login/signup/session gate) - shell (client/admin) - details (book detail/author detail/user detail)
       
  */
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
