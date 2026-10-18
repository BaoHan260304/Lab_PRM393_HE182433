import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  // Biến lưu trữ dữ liệu thô nhận về từ máy chủ
  String _rawResponse = 'Chưa có dữ liệu. Hãy bấm nút bên dưới để bắn GET request!';
  bool _isLoading = false;

  // HÀM BƠM HÚT DỮ LIỆU THÔ (Lab 8.1 - Simple GET Request)
  Future<void> _fetchRawPosts() async {
    setState(() {
      _isLoading = true;
      _rawResponse = 'Đang kết nối tới máy chủ JSONPlaceholder...';
    });

    try {
      // 1. Địa chỉ trạm máy chủ đích (Endpoint)
      final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');

      // 2. Bắn tín hiệu GET qua đường ống HTTP
      final response = await http.get(url);

      // 3. Kiểm tra mã phản hồi (200 = Thành công rực rỡ)
      if (response.statusCode == 200) {
        debugPrint('--- RAW JSON TỪ SERVER ---');
        debugPrint(response.body); // In ra bảng điều khiển console

        setState(() {
          // Hiển thị mã 200 và trích đoạn 300 ký tự đầu tiên của gói tin JSON
          _rawResponse = '✅ Mã phản hồi: ${response.statusCode} OK\n\n'
              '📦 Gói tin thô (Raw JSON):\n${response.body.substring(0, 300)}...';
        });
      } else {
        setState(() {
          _rawResponse = '❌ Lỗi từ server! Mã lỗi: ${response.statusCode}';
        });
      }
    } catch (e) {
      // Bắt các sự cố mất mạng, đứt cáp, sai URL
      setState(() {
        _rawResponse = '❌ Không thể kết nối Internet: $e';
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
        title: const Text('Lab 8.1 - Simple GET Request'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Khung hiển thị gói tin mạng nhận về
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _rawResponse,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nút bấm kích hoạt bơm hút mạng
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : _fetchRawPosts,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(
                _isLoading ? 'Đang tải dữ liệu...' : 'Bắn GET Request (Fetch Data)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
