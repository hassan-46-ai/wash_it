import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/splash.dart';
import 'state/app_state.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final state = AppState();
  @override
  Widget build(BuildContext context) => AppScope(
        state: state,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cartoon Clean Car',
          theme: buildTheme(),
          home: const SplashScreen(),
        ),
      );
}
