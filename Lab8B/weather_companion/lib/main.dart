import 'package:flutter/material.dart';
import 'weather_service.dart';

void main() {
  runApp(const WeatherCompanionApp());
}

class WeatherCompanionApp extends StatelessWidget {
  const WeatherCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Companion (Lab 8B)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const WeatherHomeScreen(),
    );
  }
}

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final WeatherService _weatherService = WeatherService();

  String _resultText = 'Chưa nạp dữ liệu khí tượng. Nhấn nút để kiểm tra kết nối vệ tinh!';
  bool _isLoading = false;

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  // THỬ NGHIỆM GỌI API THỜI TIẾT HÀ NỘI
  Future<void> _testWeatherCall() async {
    setState(() {
      _isLoading = true;
      _resultText = 'Đang bắt tín hiệu vệ tinh Open-Meteo...';
    });

    try {
      final hanoi = defaultCities.first;
      final data = await _weatherService.fetchRawWeather(
        latitude: hanoi.latitude,
        longitude: hanoi.longitude,
      );

      final current = data['current'] as Map<String, dynamic>;

      setState(() {
        _resultText = '🛰️ KẾT NỐI VỆ TINH THÀNH CÔNG (200 OK)!\n\n'
            '📍 Địa điểm: ${hanoi.name} (${hanoi.country})\n'
            '🌡️ Nhiệt độ: ${current['temperature_2m']} °C\n'
            '🤔 Cảm giác như: ${current['apparent_temperature']} °C\n'
            '💧 Độ ẩm: ${current['relative_humidity_2m']} %\n'
            '🌧️ Lượng mưa: ${current['precipitation']} mm\n'
            '💨 Tốc độ gió: ${current['wind_speed_10m']} km/h\n'
            '🏷️ Mã thời tiết (WMO Code): ${current['weather_code']}\n\n'
            '👉 Dữ liệu đã sẵn sàng để đúc khuôn Model ở Step 3!';
      });
    } catch (e) {
      setState(() {
        _resultText = '❌ Lỗi kết nối: $e';
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
        title: const Text('Weather Service Test (Step 2)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _resultText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : _testWeatherCall,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.satellite_alt_rounded),
              label: Text(
                _isLoading ? 'Đang kết nối vệ tinh...' : 'Bắn API Lấy Thời Tiết Hà Nội',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
