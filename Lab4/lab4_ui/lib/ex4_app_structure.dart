import 'package:flutter/material.dart';
import 'ex1_core_widgets.dart';
import 'ex2_input_widgets.dart';
import 'ex3_layout_basics.dart';

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  // Nhận biến và hàm từ Đạo diễn main.dart truyền vào
  const MainScreen({super.key, required this.isDarkMode, required this.toggleTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Biến lưu trữ xem người dùng đang đứng ở Tab số mấy (Mặc định là 0 - Bài 1)
  int _currentIndex = 0;

  // Lôi cả 3 bài cũ lùa vào 1 cái mảng
  final List<Widget> _screens = [
    const CoreWidgetsDemo(),
    const InputControlsDemo(),
    const LayoutBasicsDemo(),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold: Khung xương chuẩn của một chiếc App
    return Scaffold(
      // 1. THÂN APP: Hiển thị file tương ứng với Tab đang bấm
      body: _screens[_currentIndex],

      // 2. NÚT LƠ LỬNG (FAB): Dùng làm công tắc tắt/bật đèn (Dark Mode)
      floatingActionButton: FloatingActionButton(
        onPressed: widget.toggleTheme,
        backgroundColor: widget.isDarkMode ? Colors.yellow : Colors.black87,
        foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        child: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      ),

      // 3. MENU ĐIỀU HƯỚNG DƯỚI ĐÁY
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Bấm nút nào thì đổi index sang số đó và vẽ lại màn hình
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Bài 1'),
          BottomNavigationBarItem(icon: Icon(Icons.touch_app), label: 'Bài 2'),
          BottomNavigationBarItem(icon: Icon(Icons.view_list), label: 'Bài 3'),
        ],
      ),
    );
  }
}
