import 'package:flutter/material.dart';

/// KHUÔN ĐÚC DỮ LIỆU KHÍ TƯỢNG VÀ BỘ NÃO KHUYẾN NGHỊ THÔNG MINH (Purpose-driven Model)
class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  const WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  // PHỄU ĐÚC DỮ LIỆU TỪ JSON CỦA OPEN-METEO
  factory WeatherModel.fromJson({
    required Map<String, dynamic> json,
    required String cityName,
    required String country,
  }) {
    final current = json['current'] as Map<String, dynamic>? ?? {};

    return WeatherModel(
      cityName: cityName,
      country: country,
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature: (current['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      precipitation: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // ================= BỘ NÃO SUY LUẬN KHUYẾN NGHỊ THỰC TẾ =================

  /// DỊCH MÃ WMO SANG MÔ TẢ THỜI TIẾT DỄ HIỂU
  String get weatherDescription {
    if (weatherCode == 0) return 'Trời quang, nắng đẹp';
    if (weatherCode >= 1 && weatherCode <= 3) return 'Có mây rải rác';
    if (weatherCode >= 45 && weatherCode <= 48) return 'Sương mù dày đặc';
    if (weatherCode >= 51 && weatherCode <= 55) return 'Mưa phùn lất phất';
    if (weatherCode >= 61 && weatherCode <= 65) return 'Mưa rào';
    if (weatherCode >= 71 && weatherCode <= 77) return 'Tuyết rơi';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Mưa rào lớn';
    if (weatherCode >= 95) return 'Sấm sét, dông bão nguy hiểm';
    return 'Thời tiết ổn định';
  }

  /// BIỂU TƯỢNG MINH HỌA
  IconData get weatherIcon {
    if (weatherCode == 0) return Icons.wb_sunny_rounded;
    if (weatherCode >= 1 && weatherCode <= 3) return Icons.cloud_queue_rounded;
    if (weatherCode >= 45 && weatherCode <= 48) return Icons.blur_on_rounded;
    if (weatherCode >= 51 && weatherCode <= 65) return Icons.grain_rounded;
    if (weatherCode >= 71 && weatherCode <= 77) return Icons.ac_unit_rounded;
    if (weatherCode >= 80 && weatherCode <= 82) return Icons.water_drop_rounded;
    if (weatherCode >= 95) return Icons.thunderstorm_rounded;
    return Icons.wb_cloudy_rounded;
  }

  /// 1. CÂU HỎI: CÓ CẦN MANG THEO Ô / ÁO MƯA KHÔNG?
  bool get needUmbrella => precipitation > 0 || weatherCode >= 51;

  String get umbrellaAdvice {
    if (needUmbrella) {
      return '☔ CÓ: Nhớ mang theo ô hoặc áo mưa vì trời có mưa!';
    }
    return '⛱️ KHÔNG: Trời khô ráo, không cần mang theo ô!';
  }

  /// 2. CÂU HỎI: NÊN MẶC TRANG PHỤC GÌ?
  String get clothingAdvice {
    if (temperature < 18) {
      return '🧥 Trời lạnh (${temperature.toStringAsFixed(1)}°C): Nhớ mặc áo ấm hoặc mang áo khoác dày!';
    }
    if (temperature > 32) {
      return '👕 Trời nóng gắt (${temperature.toStringAsFixed(1)}°C): Mặc đồ thoáng mát, thoa kem chống nắng & uống nhiều nước!';
    }
    return '👔 Thời tiết dễ chịu (${temperature.toStringAsFixed(1)}°C): Thoải mái diện trang phục thường ngày!';
  }

  /// 3. CÂU HỎI: CÓ NÊN CHƠI THỂ THAO / HOẠT ĐỘNG NGOÀI TRỜI KHÔNG?
  String get outdoorAdvice {
    if (weatherCode >= 95) {
      return '⚡ Nguy hiểm: Có dông bão, tuyệt đối ở trong nhà!';
    }
    if (needUmbrella) {
      return '🌧️ Trời mưa trơn trượt, ưu tiên tập thể dục hoặc hoạt động trong nhà!';
    }
    if (windSpeed > 25) {
      return '💨 Gió to (${windSpeed.toStringAsFixed(1)} km/h), chú ý an toàn khi đi xe máy hoặc đạp xe!';
    }
    return '🏃 Rất thích hợp: Thời tiết lý tưởng để chạy bộ, dạo mát ngoài trời!';
  }
}
