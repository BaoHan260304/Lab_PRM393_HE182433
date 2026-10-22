import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AutoLoginLogoutApp());
}

// ================= 1. TRẠM QUẢN LÝ PHIÊN: SESSION MANAGER =================

class SessionManager {
  static const String keyToken = 'auth_token';
  static const String keyFullName = 'full_name';
  static const String keyUsername = 'username';
  static const String keyAvatar = 'avatar_url';

  /// Lưu toàn bộ thông tin phiên đăng nhập vào bộ nhớ flash qua SharedPreferences
  static Future<void> saveSession({
    required String token,
    required String fullName,
    required String username,
    required String avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyToken, token);
    await prefs.setString(keyFullName, fullName);
    await prefs.setString(keyUsername, username);
    await prefs.setString(keyAvatar, avatarUrl);
  }

  /// Trích xuất Token đã lưu
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken);
  }

  /// Đọc toàn bộ hồ sơ người dùng trong phiên
  static Future<Map<String, String?>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      keyToken: prefs.getString(keyToken),
      keyFullName: prefs.getString(keyFullName),
      keyUsername: prefs.getString(keyUsername),
      keyAvatar: prefs.getString(keyAvatar),
    };
  }

  /// Xóa sạch phiên đăng nhập khi Logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyToken);
    await prefs.remove(keyFullName);
    await prefs.remove(keyUsername);
    await prefs.remove(keyAvatar);
  }
}

// ================= 2. GỐC ỨNG DỤNG =================

class AutoLoginLogoutApp extends StatelessWidget {
  const AutoLoginLogoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.3 - Auto Login & Logout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // STEP 3: ĐẶT SPLASH SCREEN LÀM CỔNG ĐÓN TIẾP ĐẦU TIÊN CỦA APP
      home: const SplashScreen(),
    );
  }
}

// ================= 3. TRẠM GÁC CỔNG: SPLASH SCREEN (STEP 3) =================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusMessage = 'Đang khởi động cỗ máy...';

  @override
  void initState() {
    super.initState();
    _checkAuthSessionAndRoute();
  }

  /// Cỗ máy kiểm tra Token và định tuyến (Routing Engine)
  Future<void> _checkAuthSessionAndRoute() async {
    // 1. Tạo độ trễ nhân tạo 1.5 giây để màn hình Splash hiển thị mượt mà
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _statusMessage = 'Đang kiểm tra chìa khóa Token trong SharedPreferences...';
    });

    // 2. Soi trong SharedPreferences xem có Token hay không
    final String? token = await SessionManager.getToken();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // 3. ĐỊNH TUYẾN THÔNG MINH (ROUTING LOGIC)
    if (token != null && token.isNotEmpty) {
      // Đã có Token -> Định tuyến sang HomeScreen
      final session = await SessionManager.getSession();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            fullName: session[SessionManager.keyFullName] ?? 'Emily Johnson',
            username: session[SessionManager.keyUsername] ?? 'emilys',
            avatarUrl: session[SessionManager.keyAvatar] ?? '',
            token: token,
          ),
        ),
      );
    } else {
      // Chưa có Token -> Định tuyến sang LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ứng dụng với vòng bảo vệ
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 72,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Tiêu đề App
            const Text(
              'Lab 10.3 - Auth Guard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Session Persistence & Splash Routing',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),

            // Vòng quay tải trang
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Trạng thái kiểm tra Token
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 4. MÀN HÌNH ĐĂNG NHẬP (LOGIN SCREEN) =================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController =
      TextEditingController(text: 'emilys');
  final TextEditingController _passwordController =
      TextEditingController(text: 'emilyspass');

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('https://dummyjson.com/auth/login');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': _usernameController.text.trim(),
              'password': _passwordController.text,
              'expiresInMins': 30,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data['accessToken'] ?? data['token'] ?? '';
        final String fullName = '${data['firstName']} ${data['lastName']}';
        final String username = data['username'] ?? '';
        final String avatarUrl = data['image'] ?? '';

        // Lưu vào SharedPreferences
        await SessionManager.saveSession(
          token: token,
          fullName: fullName,
          username: username,
          avatarUrl: avatarUrl,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        // Điều hướng vào HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              fullName: fullName,
              username: username,
              avatarUrl: avatarUrl,
              token: token,
            ),
          ),
        );
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final String errorMsg =
            errorData['message'] ?? 'Sai tài khoản hoặc mật khẩu';

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi ($errorMsg)! Thử lại: emilys / emilyspass'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } on SocketException {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lỗi: Mất kết nối Internet!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } on TimeoutException {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Quá thời gian chờ phản hồi từ máy chủ!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Sự cố: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10.3 - Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 64,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đăng Nhập Hệ Thống',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Đăng nhập để khởi tạo phiên SharedPreferences',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.indigo, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DummyJSON Test Account:\nUsername: emilys | Pass: emilyspass',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _usernameController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'emilys',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Vui lòng nhập Username'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'emilyspass',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Vui lòng nhập Password'
                    : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _handleLogin,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login_rounded),
                label: Text(
                  _isLoading ? 'Đang xác thực...' : 'Đăng Nhập',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= 5. MÀN HÌNH TRANG CHỦ TẠM THỜI (HOME SCREEN) =================

class HomeScreen extends StatelessWidget {
  final String fullName;
  final String username;
  final String avatarUrl;
  final String token;

  const HomeScreen({
    super.key,
    required this.fullName,
    required this.username,
    required this.avatarUrl,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Xin chào, $fullName!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '@$username (Đã định tuyến từ SplashScreen thành công)',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
