import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/core/services/notification_service.dart';

import 'core/constants/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with deep link callback URL
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize OneSignal Push Notifications
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('[Notifications] Initialization failed: $e');
  }

  // Enable edge-to-edge mode for a truly immersive experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Set system overlay style globally for transparent status & navigation bars
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const ProviderScope(child: TinyStepsApp()));
}

class TinyStepsApp extends ConsumerWidget {
  const TinyStepsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Ensure status bar remains transparent on rebuilds
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp.router(
      title: 'TinySteps',
      debugShowCheckedModeBanner: false,
      theme: sunriseLightTheme(),
      darkTheme: sunriseDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
