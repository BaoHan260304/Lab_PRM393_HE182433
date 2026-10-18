import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'post_model.dart';

/// PHÒNG BAN DỊCH VỤ MẠNG CHUYÊN TRÁCH (Service Layer Pattern - Lab 8.4)
/// Chịu trách nhiệm toàn bộ các giao tiếp HTTP với bên ngoài, giải phóng UI khỏi logic mạng.
class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  // HÀM KHỞI TẠO (Hỗ trợ Dependency Injection giúp dễ dàng Unit Test)
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// BƠM HÚT DANH SÁCH BÀI POST TỪ MÁY CHỦ
  Future<List<Post>> getPosts() async {
    try {
      final url = Uri.parse('$_baseUrl/posts');

      // Gửi GET request với van an toàn Timeout 10 giây
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

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
      throw const SocketException(
        'Không có kết nối Internet! Vui lòng kiểm tra lại Wifi/4G của bạn.',
      );
    } on TimeoutException {
      throw TimeoutException(
        'Kết nối mạng quá chậm hoặc máy chủ không phản hồi (Timeout).',
      );
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu bài viết: $e');
    }
  }

  /// GIẢI PHÓNG TÀI NGUYÊN MẠNG
  void dispose() {
    _client.close();
  }
}
