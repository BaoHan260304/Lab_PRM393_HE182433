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
      home: const LoginScreen(),
    );
  }
}

// ================= 3. MÀN HÌNH ĐĂNG NHẬP (STEP 2: LƯU TOKEN VÀO SHAREDPREFERENCES) =================

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
  String? _persistedTokenPreview;

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
      _persistedTokenPreview = null;
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

        // BƯỚC 2: GHI KHẮC TOKEN VÀ HỒ SƠ VÀO BỘ NHỚ SHAREDPREFERENCES
        await SessionManager.saveSession(
          token: token,
          fullName: fullName,
          username: username,
          avatarUrl: avatarUrl,
        );

        // Đọc ngược lại từ SharedPreferences để chứng minh dữ liệu đã vào ổ cứng thiết bị
        final String? savedToken = await SessionManager.getToken();

        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _persistedTokenPreview = savedToken;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.save_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '✅ 200 OK: Đã lưu Token vào SharedPreferences thành công!\n(User: $fullName)',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.indigo,
            duration: const Duration(seconds: 4),
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
            content: Text('❌ Lỗi ($errorMsg)! Tài khoản: emilys / emilyspass'),
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
        title: const Text('Lab 10.3 - Step 2: Save Token'),
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

              // Biểu tượng lưu trữ Session
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.save_as_rounded,
                    size: 64,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lưu Session SharedPreferences',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Đăng nhập và ghi nhớ Token vào bộ nhớ flash thiết bị',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Thẻ thông tin tài khoản mẫu
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

              // Ô nhập Username
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

              // Ô nhập Password
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

              // Nút đăng nhập
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
                  _isLoading
                      ? 'Đang xử lý & lưu session...'
                      : 'Đăng Nhập & Ghi Lưu Token',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // THẺ CHỨNG MINH TOKEN ĐÃ ĐƯỢC LƯU VÀO SHAREDPREFERENCES (STEP 2 PROOF)
              if (_persistedTokenPreview != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.indigo.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.indigo.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Colors.indigo, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Đã đọc từ SharedPreferences:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            _persistedTokenPreview!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.black87,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '⚡ Khóa "auth_token" đã nằm an toàn trong bộ nhớ flash máy.',
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.indigo),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
