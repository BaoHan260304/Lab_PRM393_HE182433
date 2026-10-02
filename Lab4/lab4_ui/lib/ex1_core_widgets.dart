import 'package:flutter/material.dart';

class CoreWidgetsDemo extends StatelessWidget {
  const CoreWidgetsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 4 - Exercise 1 – Core Widgets'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // Center giúp căn giữa toàn bộ khối màn hình
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Column giống như cái cọc, xiên ngang qua các cục gạch để xếp chúng từ trên xuống
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Gạch Text
              const Text(
                'Chào mừng đến với Flutter UI!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20), // Xi măng tạo khoảng cách
              
              // 2. Gạch Icon
              const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 50,
              ),
              const SizedBox(height: 20),

              // 3. Gạch Image (lấy ảnh trực tiếp từ mạng)
              Image.network(
                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                height: 120,
              ),
              const SizedBox(height: 30),

              // 4. Gạch Card lồng bên trong là ListTile
              Card(
                elevation: 5, // Đổ bóng cho giống thẻ 3D
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Bo tròn 4 góc
                ),
                child: const ListTile(
                  leading: Icon(Icons.person, size: 40, color: Colors.blue), // Icon bên trái
                  title: Text('Nguyễn Mạnh Quân'),
                  subtitle: Text('My Flutter app'),
                  trailing: Icon(Icons.arrow_forward_ios), // Icon mũi tên bên phải
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
