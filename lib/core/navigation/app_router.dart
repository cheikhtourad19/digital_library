import 'package:digital_library/models/user_model.dart';
import 'package:digital_library/ui/pages/admin/admin_book_detail_page.dart';
import 'package:digital_library/ui/pages/admin/admin_create_book_page.dart';
import 'package:digital_library/ui/pages/admin/admin_user_detail_page.dart';
import 'package:digital_library/ui/pages/book_details/book_detail_page.dart';
import 'package:digital_library/ui/pages/client/client_cart_page.dart';
import 'package:digital_library/ui/pages/client/client_checkout_page.dart';
import 'package:digital_library/ui/pages/client/client_read_book_page.dart';
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
  static const String adminCreateBookPage = '/admin/book/create';
  static const String adminBookDetailPage = '/admin/book/detail';
  static const String clientCartPage = '/client/cart';
  static const String clientCheckoutPage = '/client/checkout';
  static const String clientBookDetailPage = '/client/book/detail';
  static const String clientReadBookPage = '/client/book/read';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case sessionGate:
        return _route(const SessionGatePage(), settings);

      case login:
        return _route(const LoginPage(), settings);

      case signup:
        return _route(const SignUpPage(), settings);

      case client:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialIndex = args?['initialIndex'] as int? ?? 0;
        return _route(ClientLayout(initialIndex: initialIndex), settings);

      case admin:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialIndex = args?['initialIndex'] as int? ?? 0;
        return _route(AdminLayout(initialIndex: initialIndex), settings);

      case adminUserDetailPage:
        final user = settings.arguments as User;
        return _route(AdminUserDetailPage(user: user), settings);
      case adminCreateBookPage:
        return _route(const AdminCreateBookPage(), settings);
      case adminBookDetailPage:
        final livreId = settings.arguments as String;
        return _route(AdminBookDetailPage(livreId: livreId), settings);
      case clientCartPage:
        return _route(ClientCartPage(), settings);
      case clientCheckoutPage:
        return _route(const ClientCheckoutPage(), settings);
      case clientBookDetailPage:
        final livreId = settings.arguments as String;
        return _route(BookDetailPage(livreId: livreId), settings);
      case clientReadBookPage:
        String livreId;
        int startPage = 0;
        if (settings.arguments is Map) {
          final args = settings.arguments as Map<String, dynamic>;
          livreId = args['livreId'] as String;
          startPage = args['startPage'] as int? ?? 0;
        } else {
          livreId = settings.arguments as String;
        }
        return _route(ClientReadBookPage(livreId: livreId, startPage: startPage), settings);
      default:
        return _route(const SessionGatePage(), settings);
    }
  }

  static MaterialPageRoute _route(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
