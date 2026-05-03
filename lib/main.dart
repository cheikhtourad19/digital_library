import 'package:digital_library/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/database_service.dart';
import 'core/navigation/app_router.dart';
import 'core/utils/toast_service.dart';
import 'ui/theme/app_theme.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  await DatabaseService.instance.database;
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(), // your existing widget
    ),
  );
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
