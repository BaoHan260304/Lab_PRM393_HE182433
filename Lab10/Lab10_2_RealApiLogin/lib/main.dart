import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RealApiLoginApp());
}

class RealApiLoginApp extends StatelessWidget {
  const RealApiLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.2 - Real API Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController(text: 'emilys');
  final TextEditingController _passwordController = TextEditingController(text: 'emilyspass');

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ================= CỖ MÁY BẮN REST API THẬT LÊN DUMMYJSON =================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. ĐỊA CHỈ TRẠM MÁY CHỦ AUTHENTICATION CỦA DUMMYJSON
      final url = Uri.parse('https://dummyjson.com/auth/login');

      // 2. BẮN GÓI TIN POST QUA ĐƯỜNG ỐNG HTTP VỚI TIMEOUT 10 GIÂY
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

      // 3. XỬ LÝ MÃ PHẢN HỒI TỪ SERVER
      if (response.statusCode == 200) {
        // ĐĂNG NHẬP THÀNH CÔNG (200 OK)
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data['accessToken'] ?? data['token'] ?? '';
        final String fullName = '${data['firstName']} ${data['lastName']}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server 200 OK: Xin chào $fullName!\n🔑 JWT Token: ${token.substring(0, 30)}...'),
            backgroundColor: Colors.teal,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // ĐĂNG NHẬP THẤT BẠI (MÃ 400 - INVALID CREDENTIALS)
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final String errorMsg = errorData['message'] ?? 'Sai tài khoản hoặc mật khẩu';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi xác thực ($errorMsg)! Thử lại: emilys / emilyspass'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on SocketException {
      // Lỗi mất kết nối Internet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Mất kết nối Internet! Vui lòng kiểm tra Wifi/4G.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } on TimeoutException {
      // Lỗi mạng quá yếu hoặc máy chủ bị nghẽn
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Quá thời gian chờ phản hồi từ máy chủ (Timeout).'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      // Sự cố không xác định khác
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Sự cố: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10.2 - DummyJSON Real API'),
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
              const SizedBox(height: 20),

              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_sync_rounded,
                    size: 64,
                    color: Colors.teal,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đăng Nhập REST API Thật',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Xác thực và lấy JWT Token từ dummyjson.com',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Thẻ gợi ý tài khoản test của DummyJSON
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.teal, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tài khoản DummyJSON hợp lệ:\nUsername: emilys | Pass: emilyspass',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ô USERNAME
              TextFormField(
                controller: _usernameController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập (Username)',
                  hintText: 'emilys',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập Username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ô PASSWORD
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu (Password)',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // NÚT BẤM ĐĂNG NHẬP BẮN API
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Đăng Nhập (Call Real API)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
