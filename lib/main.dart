import 'package:flutter/material.dart';

import 'src/features/home/presenter/ui/pages/home_page.dart';
import 'src/features/register/presenter/ui/pages/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo Monolith',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const HomePage(),
        '/register': (BuildContext context) => const RegisterPage(),
      },
    );
  }
}
