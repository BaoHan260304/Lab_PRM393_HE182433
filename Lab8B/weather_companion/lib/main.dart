import 'package:flutter/material.dart';
import 'weather_model.dart';
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

  WeatherModel? _weather;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  // TẢI VÀ ĐÚC KHUÔN THỜI TIẾT HÀ NỘI
  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final hanoi = defaultCities.first;
      final result = await _weatherService.getWeather(hanoi);

      setState(() {
        _weather = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
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
        title: const Text('Weather Companion (Step 3)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchWeather,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang nạp dữ liệu vào WeatherModel...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_errorMessage, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchWeather, child: const Text('Thử lại')),
                      ],
                    ),
                  ),
                )
              : _weather == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Thẻ thời tiết tổng quan
                          Card(
                            elevation: 3,
                            color: Colors.teal.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Text(
                                    '${_weather!.cityName}, ${_weather!.country}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(_weather!.weatherIcon, size: 64, color: Colors.teal),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_weather!.temperature.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  Text(
                                    _weather!.weatherDescription,
                                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  Text(
                                    'Cảm giác thực tế: ${_weather!.apparentTemperature.toStringAsFixed(1)}°C',
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2. BỘ NÃO KHUYẾN NGHỊ THỰC TẾ (Purpose-Driven Section)
                          const Text(
                            '💡 Gợi ý thực tế hôm nay:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

                          _buildAdviceTile(
                            icon: Icons.umbrella_rounded,
                            title: 'Mang ô / áo mưa?',
                            advice: _weather!.umbrellaAdvice,
                            isWarning: _weather!.needUmbrella,
                          ),
                          const SizedBox(height: 8),

                          _buildAdviceTile(
                            icon: Icons.checkroom_rounded,
                            title: 'Trang phục khuyên dùng',
                            advice: _weather!.clothingAdvice,
                            isWarning: false,
                          ),
                          const SizedBox(height: 8),

                          _buildAdviceTile(
                            icon: Icons.directions_run_rounded,
                            title: 'Hoạt động ngoài trời',
                            advice: _weather!.outdoorAdvice,
                            isWarning: _weather!.needUmbrella,
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildAdviceTile({
    required IconData icon,
    required String title,
    required String advice,
    required bool isWarning,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isWarning ? Colors.orange.shade100 : Colors.teal.shade100,
          child: Icon(icon, color: isWarning ? Colors.deepOrange : Colors.teal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(advice, style: TextStyle(color: Colors.grey.shade800, height: 1.3)),
        ),
      ),
    );
  }
}
