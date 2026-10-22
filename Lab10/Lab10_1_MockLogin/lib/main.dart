import 'package:flutter/material.dart';

void main() {
  runApp(const MockLoginApp());
}

class MockLoginApp extends StatelessWidget {
  const MockLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.1 - Mock Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// ================= 1. TRẠM GÁC CỔNG: MÀN HÌNH ĐĂNG NHẬP (LOGIN SCREEN) =================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ email';
    }
    final email = value.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'Email không đúng định dạng (vd: admin@test.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    // Giả lập độ trễ mạng 2 giây
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email == 'admin@test.com' && password == '123456') {
      const mockToken = 'mock_jwt_token_987654321_success';

      setState(() {
        _isLoading = false;
      });

      // ĐIỀU HƯỚNG VÀO HOME: Dùng pushReplacement để xóa trang Login khỏi ngăn xếp RAM
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            email: email,
            token: mockToken,
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Sai email hoặc mật khẩu! (Thử: admin@test.com / 123456)'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10.1 - Mock Login'),
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
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 64,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đăng Nhập Giả Lập',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Tài khoản test: admin@test.com | Pass: 123456',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'admin@test.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: '123456',
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
                validator: _validatePassword,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
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
                        'Đăng Nhập (Sign In)',
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

// ================= 2. PHÒNG KHÁCH CHÍNH: MÀN HÌNH TRANG CHỦ (HOME SCREEN) =================

class HomeScreen extends StatelessWidget {
  final String email;
  final String token;

  const HomeScreen({
    super.key,
    required this.email,
    required this.token,
  });

  void _handleLogout(BuildContext context) {
    // Đăng xuất: Đưa người dùng trở về màn hình Login và hủy Home khỏi RAM
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('👋 Đã đăng xuất thành công!'),
        backgroundColor: Colors.indigo,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Chủ (Home Screen)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Avatar người dùng
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(
                  Icons.person_rounded,
                  size: 54,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Xin chào người dùng!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Thẻ hiển thị thông tin phiên Mock Token
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.key_rounded, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Mã Token Xác Thực (Mock JWT):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        token,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Trạng thái: Đã xác thực thành công (Lab 10.1)',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Nút bấm đăng xuất
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.redAccent),
                foregroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Đăng Xuất (Logout)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
