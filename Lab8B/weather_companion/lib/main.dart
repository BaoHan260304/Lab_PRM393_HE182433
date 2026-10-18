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

  // Thành phố đang được chọn (Mặc định: Hà Nội)
  CityLocation _selectedCity = defaultCities.first;

  WeatherModel? _weather;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherForCity(_selectedCity);
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  // TẢI DỮ LIỆU THỜI TIẾT CHO THÀNH PHỐ ĐƯỢC CHỌN
  Future<void> _fetchWeatherForCity(CityLocation city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _weatherService.getWeather(city);
      if (mounted) {
        setState(() {
          _weather = result;
          _selectedCity = city;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // VUỐT ĐỂ LÀM MỚI (Pull-to-refresh)
  Future<void> _onRefresh() async {
    await _fetchWeatherForCity(_selectedCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.wb_twilight_rounded, color: Colors.teal),
            SizedBox(width: 8),
            Text(
              'Weather Companion',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Cập nhật',
            onPressed: _isLoading ? null : () => _fetchWeatherForCity(_selectedCity),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. THANH CHỌN THÀNH PHỐ (City Selector Chips)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: defaultCities.map((city) {
                  final isSelected = city.name == _selectedCity.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(city.name),
                      selected: isSelected,
                      selectedColor: Colors.teal.shade100,
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.teal.shade900 : Colors.black87,
                      ),
                      onSelected: (selected) {
                        if (selected && city.name != _selectedCity.name) {
                          _fetchWeatherForCity(city);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // 2. KHU VỰC HIỂN THỊ CHÍNH (VỚI VUỐT ĐỂ LÀM MỚI)
          Expanded(
            child: _isLoading && _weather == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.teal),
                        const SizedBox(height: 16),
                        Text(
                          'Đang kết nối vệ tinh tại ${_selectedCity.name}...',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                        ),
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
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cloud_off_rounded,
                                  size: 54,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Không thể lấy dữ liệu thời tiết',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _fetchWeatherForCity(_selectedCity),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại ngay'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.teal,
                        onRefresh: _onRefresh,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // A. THẺ THỜI TIẾT TRUNG TÂM (Hero Weather Card)
                              Container(
                                padding: const EdgeInsets.all(22.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.teal.shade500, Colors.teal.shade700],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${_weather!.cityName}, ${_weather!.country}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (_isLoading)
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Icon(
                                      _weather!.weatherIcon,
                                      size: 72,
                                      color: Colors.yellow.shade200,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${_weather!.temperature.toStringAsFixed(1)}°C',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    Text(
                                      _weather!.weatherDescription,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Cảm giác thực tế: ${_weather!.apparentTemperature.toStringAsFixed(1)}°C',
                                      style: TextStyle(
                                        color: Colors.teal.shade100,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // B. BẢNG ĐỒNG HỒ 3 CHỈ SỐ MÔI TRƯỜNG (Metrics Row)
                              Row(
                                children: [
                                  _buildMetricCard(
                                    title: 'Độ ẩm',
                                    value: '${_weather!.humidity}%',
                                    icon: Icons.water_drop_outlined,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 10),
                                  _buildMetricCard(
                                    title: 'Tốc độ gió',
                                    value: '${_weather!.windSpeed.toStringAsFixed(1)} km/h',
                                    icon: Icons.air_rounded,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(width: 10),
                                  _buildMetricCard(
                                    title: 'Lượng mưa',
                                    value: '${_weather!.precipitation.toStringAsFixed(1)} mm',
                                    icon: Icons.grain_rounded,
                                    color: Colors.indigo,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // C. BỘ NÃO LỜI KHUYÊN THỰC TẾ (Purpose-Driven Guidance)
                              const Row(
                                children: [
                                  Icon(Icons.lightbulb_rounded, color: Colors.amber),
                                  SizedBox(width: 6),
                                  Text(
                                    'Lời khuyên hôm nay cho bạn',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              _buildAdviceCard(
                                icon: Icons.umbrella_rounded,
                                title: 'Có cần mang ô không?',
                                advice: _weather!.umbrellaAdvice,
                                isWarning: _weather!.needUmbrella,
                              ),
                              const SizedBox(height: 10),

                              _buildAdviceCard(
                                icon: Icons.checkroom_rounded,
                                title: 'Gợi ý trang phục',
                                advice: _weather!.clothingAdvice,
                                isWarning: false,
                              ),
                              const SizedBox(height: 10),

                              _buildAdviceCard(
                                icon: Icons.directions_run_rounded,
                                title: 'Hoạt động ngoài trời',
                                advice: _weather!.outdoorAdvice,
                                isWarning: _weather!.needUmbrella,
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // WIDGET THẺ ĐỒNG HỒ CHỈ SỐ
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET THẺ LỜI KHUYÊN THỰC TẾ
  Widget _buildAdviceCard({
    required IconData icon,
    required String title,
    required String advice,
    required bool isWarning,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isWarning ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWarning ? Colors.orange.shade300 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isWarning ? Colors.orange.shade100 : Colors.teal.shade100,
            radius: 20,
            child: Icon(icon, color: isWarning ? Colors.deepOrange : Colors.teal, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: TextStyle(
                    color: isWarning ? Colors.deepOrange.shade900 : Colors.grey.shade800,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
