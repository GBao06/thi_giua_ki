import 'package:flutter/material.dart';

import 'pages/login_page.dart';

void main() => runApp(const EasyShopApp());

class EasyShopApp extends StatelessWidget {
  const EasyShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      // Mở app là vào trang đăng nhập
      home: const LoginPage(),
    );
  }
}
