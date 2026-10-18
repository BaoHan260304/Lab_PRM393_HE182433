import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'post_model.dart';

/// PHÒNG BAN DỊCH VỤ MẠNG CHUYÊN TRÁCH (Service Layer Pattern - Lab 8.4)
class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// 1. BƠM HÚT DANH SÁCH BÀI POST (GET Request)
  Future<List<Post>> getPosts() async {
    try {
      final url = Uri.parse('$_baseUrl/posts');
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
      throw Exception('Lỗi khi lấy dữ liệu: $e');
    }
  }

  /// 2. BẮN GỬI BÀI VIẾT MỚI LÊN MÁY CHỦ (POST Request - Step 7 & Bonus)
  Future<Post> createPost({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/posts');

      // Gửi POST request kèm tiêu chuẩn Header JSON
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'title': title,
              'body': body,
              'userId': userId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      // Mã 201 Created: Máy chủ đã tạo mới thành công tài nguyên
      if (response.statusCode == 201) {
        final dynamic jsonResponse = jsonDecode(response.body);
        return Post.fromJson(jsonResponse as Map<String, dynamic>);
      } else {
        throw HttpException(
          'Tạo bài viết thất bại! Mã lỗi từ máy chủ: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException('Không thể gửi bài viết: Mất kết nối Internet.');
    } on TimeoutException {
      throw TimeoutException('Quá thời gian chờ phản hồi từ máy chủ.');
    } catch (e) {
      throw Exception('Lỗi tạo bài viết: $e');
    }
  }

  /// GIẢI PHÓNG TÀI NGUYÊN MẠNG
  void dispose() {
    _client.close();
  }
}
