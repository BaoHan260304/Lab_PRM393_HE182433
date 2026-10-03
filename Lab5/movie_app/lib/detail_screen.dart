import 'package:flutter/material.dart';
import 'movie_model.dart';

class DetailScreen extends StatefulWidget {
  // Trạm thu phí: Khai báo sẵn cái giỏ (movie) để đón gói hàng từ trang Home quăng sang
  final Movie movie; 

  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // [Nhiệm vụ tuỳ chọn]: Trạng thái tắt/bật nút thả tim
  bool isFavorite = false; 

  @override
  Widget build(BuildContext context) {
    // Gọi "widget.movie" để lấy đồ trong giỏ ra xài
    final movie = widget.movie; 

    return Scaffold(
      backgroundColor: Colors.white,
      // Lệnh ma thuật: Kéo nguyên cái body trượt xuống nằm chìm bên dưới AppBar
      extendBodyBehindAppBar: true, 
      
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar trong suốt tàng hình
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh Poster siêu to khổng lồ (Hero Banner)
            // Dùng Stack để đè lớp màn đen gradient lên trên tấm ảnh, giúp chữ không bị chìm
            Stack(
              children: [
                Image.network(movie.posterUrl, width: double.infinity, height: 450, fit: BoxFit.cover),
                Container(
                  width: double.infinity,
                  height: 450,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5), // Đen mờ ở trên đỉnh
                        Colors.transparent,
                        Colors.white, // Trắng dần về dưới đáy để hoà vào nền trang
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // 2. Nội dung chi tiết phim
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên phim và Điểm số
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(movie.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 28),
                          Text(movie.rating.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Thể loại (Dùng bùa Wrap để nếu dài quá thì tự rớt dòng)
                  Wrap(
                    spacing: 8.0,
                    children: movie.genres.map((genre) {
                      return Chip(
                        label: Text(genre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        side: const BorderSide(color: Colors.redAccent),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Các nút bấm tương tác
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 30),
                            onPressed: () {
                              setState(() => isFavorite = !isFavorite); // Đảo trạng thái tim
                            },
                          ),
                          const Text('Yêu thích')
                        ],
                      ),
                      const Column(
                        children: [
                          IconButton(icon: Icon(Icons.star_border, size: 30), onPressed: null),
                          Text('Đánh giá')
                        ],
                      ),
                      const Column(
                        children: [
                          IconButton(icon: Icon(Icons.share, size: 30), onPressed: null),
                          Text('Chia sẻ')
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tóm tắt nội dung
                  const Text('Nội dung phim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(movie.overview, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 20),

                  // Danh sách Trailer
                  const Text('Trailers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  // Chú ý: Bọc ListView con bên trong ListView/ScrollView cha phải bật shrinkWrap = true
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(), // Khoá chức năng cuộn của ListView con
                    itemCount: movie.trailers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.play_circle_fill, color: Colors.red, size: 35),
                        title: Text(movie.trailers[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
