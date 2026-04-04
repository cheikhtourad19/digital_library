import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../service/auth_service.dart';

class SessionGatePage extends StatefulWidget {
  const SessionGatePage({super.key});

  @override
  State<SessionGatePage> createState() => _SessionGatePageState();
}

class _SessionGatePageState extends State<SessionGatePage> {
  final AuthService _authService = AuthService();
  bool _didRedirect = false;

  Future<String> _resolveStartRoute() async {
    final token = await _authService.getSessionToken();

    if (token == null || token.isEmpty) {
      return AppRouter.login;
    }

    final role = await _authService.getUserRole();

    if (role == UserRole.admin) {
      return AppRouter.adminHome;
    }

    return AppRouter.clientHome;
  }

  Future<void> _redirect() async {
    if (_didRedirect) return;
    _didRedirect = true;

    try {
      final route = await _resolveStartRoute();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(route);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Session check failed: $error')));
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
