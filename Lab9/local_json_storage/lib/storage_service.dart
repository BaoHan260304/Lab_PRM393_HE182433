import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'product_model.dart';

/// DỊCH VỤ QUẢN LÝ LƯU TRỮ TỆP TIN CỤC BỘ (Storage Service - Lab 9.2)
class StorageService {
  static const String _fileName = 'local_products.json';

  /// 1. TÌM ĐƯỜNG DẪN Ổ CỨNG VẬT LÝ AN TOÀN TRÊN THIẾT BỊ
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  /// LẤY ĐƯỜNG DẪN DƯỚI DẠNG CHUỖI ĐỂ HIỂN THỊ LÊN UI CHO GIẢNG VIÊN XEM
  Future<String> getFilePath() async {
    final file = await _getLocalFile();
    return file.path;
  }

  /// 2. ĐỌC DANH SÁCH SẢN PHẨM TỪ Ổ CỨNG MÁY THẬT
  Future<List<Product>> loadProducts() async {
    try {
      final file = await _getLocalFile();

      // Nếu file chưa từng tồn tại (lần đầu khởi động App)
      if (!await file.exists()) {
        // Sao chép 5 sản phẩm mẫu từ Assets sang làm dữ liệu khởi tạo ban đầu
        final String assetString = await rootBundle.loadString('assets/data/products.json');
        await file.writeAsString(assetString);
      }

      // Đọc toàn bộ nội dung file JSON từ ổ cứng
      final String contents = await file.readAsString();
      if (contents.trim().isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Không thể đọc file từ bộ nhớ máy: $e');
    }
  }

  /// 3. GHI DANH SÁCH SẢN PHẨM XUỐNG Ổ CỨNG CỤC BỘ (LƯU VĨNH VIỄN)
  Future<File> saveProducts(List<Product> products) async {
    try {
      final file = await _getLocalFile();

      // Chuyển danh sách Model thành chuỗi JSON được định dạng thụt dòng đẹp mắt
      final List<Map<String, dynamic>> jsonList =
          products.map((p) => p.toJson()).toList();
      final String jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

      // Ghi đè vào file trên đĩa cứng
      return await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception('Không thể ghi file vào ổ cứng: $e');
    }
  }
}
