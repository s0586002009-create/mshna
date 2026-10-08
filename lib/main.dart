import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/database.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = NotificationService();
  await notifications.init();
  final state = AppState(AppDatabase(), notifications);
  await state.init();
  runApp(MishnahApp(state: state));
}

class MishnahApp extends StatelessWidget {
  final AppState state;
  const MishnahApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: state,
        builder: (_, __) => MaterialApp(
          title: 'משניות',
          debugShowCheckedModeBanner: false,
          locale: const Locale('he'),
          supportedLocales: const [Locale('he')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          themeMode: state.theme,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: state.loading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : state.onboardingDone
                  ? HomeScreen(state: state)
                  : OnboardingScreen(state: state),
        ),
      );
}

ThemeData _theme(Brightness brightness) => ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'DejaVuSans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7A5637),
        brightness: brightness,
      ),
      scaffoldBackgroundColor:
          brightness == Brightness.light ? const Color(0xFFF7F0E5) : const Color(0xFF211A14),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
