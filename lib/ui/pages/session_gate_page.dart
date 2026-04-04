import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../service/auth_service.dart';
import '../../core/utils/app_colors.dart';

class SessionGatePage extends StatefulWidget {
  const SessionGatePage({super.key});

  @override
  State<SessionGatePage> createState() => _SessionGatePageState();
}

class _SessionGatePageState extends State<SessionGatePage> {
  final AuthService _authService = AuthService();
  bool _didRedirect = false;

  Future<String> _resolveStartRoute() async {
    // ✅ checks both token existence and expiry
    final isValid = await _authService.isSessionValid();

    if (!isValid) return AppRouter.login;

    final role = await _authService.getUserRole();

    return role == UserRole.admin ? AppRouter.admin : AppRouter.client;
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
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
    );
  }
}
