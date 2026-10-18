import 'dart:convert';
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
  // DANH SÁCH BỘ NHỚ LƯU TRỮ CÁC BÀI POST ĐÃ ĐÚC KHUÔN THÀNH CÔNG
  List<Post> _posts = [];
  String _statusMessage = 'Chưa có bài viết nào được nạp vào bộ nhớ.';
  bool _isLoading = false;

  // HÀM BƠM HÚT & ĐÚC KHUÔN JSON THÀNH LIST<POST> (Lab 8.2)
  Future<void> _fetchAndParsePosts() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang tải dữ liệu và đúc khuôn JSON...';
    });

    try {
      final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 1. CỐI XAY JSON: Chuyển chuỗi String thô thành danh sách động (List<dynamic>)
        final List<dynamic> jsonList = jsonDecode(response.body);

        // 2. PHỄU ĐÚC MODEL: Dùng khuôn Post.fromJson biến từng phần tử thành Object Post
        final List<Post> parsedPosts = jsonList
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          _posts = parsedPosts;
          _statusMessage = '🎉 Đúc khuôn thành công ${_posts.length} bài Post vào RAM!';
        });

        debugPrint('Số lượng bài Post đã parse: ${_posts.length}');
      } else {
        setState(() {
          _statusMessage = '❌ Server trả về lỗi: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi mạng: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 8.2 - JSON → Model Parsing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ trạng thái thông báo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _posts.isNotEmpty ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _posts.isNotEmpty ? Colors.green.shade300 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _posts.isNotEmpty ? Icons.check_circle : Icons.info,
                    color: _posts.isNotEmpty ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Khung hiển thị thử nghiệm bài Post đầu tiên đã đúc khuôn thành công
            Expanded(
              child: _posts.isEmpty
                  ? Center(
                      child: Text(
                        _isLoading
                            ? 'Đang kéo dữ liệu từ đám mây...'
                            : 'Nhấn nút phía dưới để nạp dữ liệu vào khuôn Model',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text('Post #${_posts.first.id}'),
                                  backgroundColor: Colors.blue.shade100,
                                ),
                                Text(
                                  'User ID: ${_posts.first.userId}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Text(
                              _posts.first.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _posts.first.body,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                            const Spacer(),
                            Text(
                              '...và còn ${_posts.length - 1} bài viết khác đã sẵn sàng ở Step 4!',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Nút bấm kích hoạt tiến trình
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : _fetchAndParsePosts,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.transform),
              label: Text(
                _isLoading ? 'Đang đúc khuôn Model...' : 'Đúc khuôn Model (Parse JSON)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
