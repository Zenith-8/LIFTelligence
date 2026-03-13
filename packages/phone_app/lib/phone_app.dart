library phone_app;

import 'package:flutter/material.dart';

import 'src/ui/home_page.dart';

class PhoneAppRoot extends StatelessWidget {
  const PhoneAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

