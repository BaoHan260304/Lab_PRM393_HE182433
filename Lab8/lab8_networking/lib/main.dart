import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'post_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 8 - Networking & REST API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const PostListScreen(),
    );
  }
}

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchPosts();
  }

  // CẦN GẠT THỬ LẠI: Kích hoạt lại tiến trình nạp dữ liệu từ đầu
  void _retryFetch() {
    setState(() {
      _postsFuture = _fetchPosts();
    });
  }

  // HÀM BƠM HÚT MẠNG CÓ CẢM BIẾN BẮT LỖI & TIMEOUT (Lab 8.3)
  Future<List<Post>> _fetchPosts() async {
    try {
      final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');

      // CẢM BIẾN CHỐNG TREO MÁY: Quá 10 giây không có mạng -> Tự ngắt kết nối
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Máy chủ phản hồi mã lỗi ${response.statusCode}: Không thể lấy dữ liệu.',
        );
      }
    } on SocketException {
      // Bắt lỗi mất kết nối Internet hoàn toàn (chế độ máy bay, đứt wifi)
      throw const SocketException(
        'Không có kết nối Internet! Vui lòng kiểm tra lại Wifi/4G của bạn.',
      );
    } on TimeoutException {
      // Bắt lỗi mạng quá yếu hoặc máy chủ bị sập
      throw TimeoutException(
        'Kết nối mạng quá chậm hoặc máy chủ không phản hồi (Timeout).',
      );
    } catch (e) {
      // Các lỗi ngoại lệ phát sinh khác
      throw Exception('Đã xảy ra sự cố không xác định: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (Error Handling & Retry)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Nút bấm làm mới nhanh trên thanh công cụ
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: _retryFetch,
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          // 1. TRẠNG THÁI CHỜ MẠNG (Loading State)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải bài viết...',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 2. TRẠNG THÁI GẶP SỰ CỐ + NÚT BẤM THỬ LẠI (Error State & Retry)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        size: 64,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rất tiếc! Đã có lỗi xảy ra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    // CẦN GẠT THỬ LẠI (RETRY BUTTON)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _retryFetch,
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Thử lại ngay (Retry)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. TRẠNG THÁI DỮ LIỆU ĐÃ VỀ KHO (Data State)
          if (snapshot.hasData) {
            final posts = snapshot.data!;

            if (posts.isEmpty) {
              return const Center(child: Text('Không có bài viết nào.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        '#${post.id}',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
