import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phim Thịnh Hành', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: sampleMovies.length,
        itemBuilder: (context, index) {
          final movie = sampleMovies[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              
              // Cắt bo góc tấm ảnh Poster thu nhỏ
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(movie.posterUrl, width: 60, height: 90, fit: BoxFit.cover),
              ),
              title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('⭐ ${movie.rating}   •   ${movie.genres.join(', ')}'),
              
              // SỰ KIỆN: BẤM VÀO PHIM THÌ CHUYỂN TRANG
              onTap: () {
                // [CƠ KHÍ CỐT LÕI]: Cỗ máy Navigator.push
                // Mở cửa sang trang DetailScreen, đồng thời "đóng gói" bộ phim (movie) truyền sang đó.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(movie: movie),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
