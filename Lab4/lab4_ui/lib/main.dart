import 'package:flutter/material.dart';
import 'ex1_core_widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 4 UI Fundamentals',
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG xấu xí ở góc phải màn hình
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Thay vì chạy code mặc định của Flutter, mình trỏ nó sang file Ex 1
      home: const CoreWidgetsDemo(), 
    );
  }
}
