import 'package:flutter/material.dart';
import 'core/database/database_service.dart';
import 'core/navigation/app_router.dart';
import 'core/utils/toast_service.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Library',
      theme: AppTheme.light,
      scaffoldMessengerKey: ToastService.scaffoldMessengerKey,
      initialRoute: AppRouter.sessionGate,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
