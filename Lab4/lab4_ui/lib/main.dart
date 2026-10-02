import 'package:flutter/material.dart';
import 'ex3_layout_basics.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 4 UI Fundamentals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Đổi cầu dao sang bài 3
      home: const LayoutBasicsDemo(), 
    );
  }
}
