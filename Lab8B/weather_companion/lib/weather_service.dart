import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

/// VỊ TRÍ TỌA ĐỘ ĐỊA LÝ CỦA CÁC THÀNH PHỐ
class CityLocation {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const CityLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => '$name ($country)';
}

/// DANH MỤC CÁC THÀNH PHỐ MẶC ĐỊNH
const List<CityLocation> defaultCities = [
  CityLocation(name: 'Hà Nội', country: 'Việt Nam', latitude: 21.0285, longitude: 105.8542),
  CityLocation(name: 'TP. Hồ Chí Minh', country: 'Việt Nam', latitude: 10.8231, longitude: 106.6297),
  CityLocation(name: 'Đà Nẵng', country: 'Việt Nam', latitude: 16.0544, longitude: 108.2022),
  CityLocation(name: 'Tokyo', country: 'Nhật Bản', latitude: 35.6762, longitude: 139.6503),
  CityLocation(name: 'Paris', country: 'Pháp', latitude: 48.8566, longitude: 2.3522),
  CityLocation(name: 'New York', country: 'Mỹ', latitude: 40.7128, longitude: -74.0060),
];

/// TẦNG DỊCH VỤ MẠNG THỜI TIẾT (Weather Service - Service Layer Pattern)
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// 1. GỌI VỆ TINH LẤY DỮ LIỆU THÔ
  Future<Map<String, dynamic>> fetchRawWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      );

      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw HttpException('Máy chủ khí tượng báo lỗi: ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('Mất kết nối Internet! Vui lòng bật Wifi/4G.');
    } on TimeoutException {
      throw TimeoutException('Quá thời gian kết nối tới vệ tinh thời tiết (Timeout).');
    } catch (e) {
      throw Exception('Lỗi dịch vụ thời tiết: $e');
    }
  }

  /// 2. LẤY THỜI TIẾT VÀ TỰ ĐỘNG ĐÚC KHUÔN MODEL (WeatherModel)
  Future<WeatherModel> getWeather(CityLocation city) async {
    final rawData = await fetchRawWeather(
      latitude: city.latitude,
      longitude: city.longitude,
    );

    return WeatherModel.fromJson(
      json: rawData,
      cityName: city.name,
      country: city.country,
    );
  }

  void dispose() {
    _client.close();
  }
}
