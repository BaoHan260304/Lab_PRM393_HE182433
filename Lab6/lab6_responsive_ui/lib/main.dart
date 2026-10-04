import 'package:flutter/material.dart';

void main() {
  runApp(const ResponsiveMovieApp());
}

// Cầu dao tổng của hệ thống
class ResponsiveMovieApp extends StatelessWidget {
  const ResponsiveMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Movie UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GenreScreen(),
    );
  }
}

// Màn hình chính (Stateful vì lát nữa phải bấm lọc phim liên tục)
class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  // Biến lưu trữ từ khoá tìm kiếm (Step 4)
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền hơi xám nhẹ cho sang
      // Khiên SafeArea giúp nội dung không bị lẹm vào camera tai thỏ
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề to chà bá
              const Text(
                'Find a Movie',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // ---------------------------------------------------------
              // CHỖ TRỐNG ĐỂ LÁT NỮA LẮP RÁP CÁC BỘ PHẬN Ở STEP SAU VÀO
              // ---------------------------------------------------------
              // --- STEP 4: THANH TÌM KIẾM (SEARCH BAR) ---
              TextField(
                onChanged: (value) {
                  // Gõ tới đâu, cập nhật biến tới đó để bắt giao diện vẽ lại
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Nhập tên phim cần tìm...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Bo góc tròn vo
                    borderSide: BorderSide.none, // Xoá viền đen
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.green[100],
                child: const Text('Bầy nút Thể loại sẽ lắp ở đây (Step 5)'),
              ),
              const SizedBox(height: 10),
              
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.blue[100],
                child: const Text('Nút Sắp xếp sẽ lắp ở đây (Step 6)'),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.red[100],
                  child: const Center(child: Text('Danh sách phim sẽ hiển thị ở đây (Step 8) 🎬')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
