import 'package:flutter/material.dart';

class LayoutBasicsDemo extends StatelessWidget {
  const LayoutBasicsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Một danh sách data giả lập để bỏ vào băng chuyền
    final List<String> movies = [
      'Interstellar', 'Inception', 'The Matrix', 'Avatar', 
      'Joker', 'Batman', 'Spiderman', 'Iron Man', 
      'Oppenheimer', 'Dune'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 4 - Exercise 3 – Layout Basics'),
        backgroundColor: Colors.greenAccent,
      ),
      // Column: Đóng 1 cái cọc dọc để xếp các tầng nhà
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
        children: [
          // TẦNG 1: Tiêu đề
          // Padding: Trát xi-măng tạo khoảng trống 16px ở cả 4 viền để chữ không bị sát mép màn hình
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Phim thịnh hành tuần này',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          
          // TẦNG 2: Băng chuyền danh sách (ListView)
          // Ex5: Bắt buộc phải bọc ListView trong Expanded.
          // Nếu không bọc, App sẽ nổ tung vì ListView không biết mình được kéo dài tới đâu.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Đẩy viền trái/phải vào 16px
              itemCount: movies.length, // Cỗ máy biết có tổng cộng bao nhiêu bộ phim
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0), // Xi-măng tàng hình dãn cách các thẻ 12px
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.movie, color: Colors.purple, size: 30),
                    title: Text(movies[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Nhấn để xem chi tiết...'),
                    trailing: const Icon(Icons.play_circle_fill, color: Colors.green),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
