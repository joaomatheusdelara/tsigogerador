import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsigo_gerador/theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard.dart';
import 'providers/shared_prefs_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> limparSeNaoLembrar() async {
  final prefs = await SharedPreferences.getInstance();
  final lembrar = prefs.getBool("lembrar_me") ?? false;

  if (!lembrar) {
    await prefs.remove("token");
    await prefs.remove("nome");
    await prefs.remove("nome_tipo");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF114474),
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  await limparSeNaoLembrar();
  final token = prefs.getString("token");

  final bool tokenValido = token != null && token.isNotEmpty;

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: MyApp(
        startScreen: tokenValido
            ? const DashboardScreen()
            : const LoginScreen(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget startScreen;
  const MyApp({super.key, required this.startScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  final title = message.notification?.title;
  final body = message.notification?.body;

  if (title != null && body != null && navigatorKey.currentContext != null) {
    showCupertinoDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(navigatorKey.currentContext!),
          ),
        ],
      ),
    );
  } else {
    debugPrint("🔕 Notificação sem título ou corpo ignorada.");
  }
});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoTheme,
      navigatorKey: navigatorKey,
      home: widget.startScreen,
    );
  }
}