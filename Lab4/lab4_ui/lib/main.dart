import 'package:flutter/material.dart';
import 'ex4_app_structure.dart';

void main() {
  runApp(const Ex4App());
}

// Lần này Đạo diễn main.dart phải lên đời thành StatefulWidget 
// để có bộ nhớ ghi nhớ xem App đang ở chế độ Sáng hay Tối
class Ex4App extends StatefulWidget {
  const Ex4App({super.key});

  @override
  State<Ex4App> createState() => _Ex4AppState();
}

class _Ex4AppState extends State<Ex4App> {
  // Mặc định là Tắt Dark Mode
  bool _isDarkMode = false;

  // Hàm đảo ngược trạng thái đèn
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 4 UI Fundamentals',
      debugShowCheckedModeBanner: false,
      
      // Khai báo 2 bộ màu Sáng / Tối cho hệ thống
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      
      // Chốt hạ: App đang chạy theo giao diện nào?
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Giao việc hiển thị khung màn hình cho file Ex4
      home: MainScreen(
        isDarkMode: _isDarkMode,
        toggleTheme: _toggleTheme,
      ), 
    );
  }
}
