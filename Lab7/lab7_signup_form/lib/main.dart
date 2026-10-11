import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 7 - Signup Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignupScreen(),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // CẦU DAO TỔNG: Quản lý Form
  final _formKey = GlobalKey<FormState>();

  // CÁC THƯ KÝ THEO DÕI NỘI DUNG (CONTROLLERS)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // TRẠM THU PHÁT SÓNG ĐIỀU HƯỚNG CON TRỎ (FOCUS NODES)
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // BIẾN TRẠNG THÁI (STATE)
  bool _obscurePassword = true; // Trạng thái ẩn/hiện mật khẩu
  bool _obscureConfirmPassword = true; // Trạng thái ẩn/hiện xác nhận mật khẩu
  bool _isCheckingEmail = false; // Trạng thái kiểm tra email bất đồng bộ (Loading)

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  // ================= CÁC TRẠM KIỂM SOÁT ĐỒNG BỘ (SYNC VALIDATORS) =================

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least 1 digit';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ================= CỖ MÁY XỬ LÝ SUBMIT & ASYNC VALIDATION =================

  Future<void> _submitForm() async {
    // 1. Hạ bàn phím ảo xuống
    FocusScope.of(context).unfocus();

    // 2. Chạy kiểm tra đồng bộ tại chỗ (Form validation)
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    // 3. Bật chế độ Loading: Đổi nút bấm thành vòng xoay và khóa nút
    setState(() {
      _isCheckingEmail = true;
    });

    // 4. Giả lập gửi request lên server (chờ 2 giây)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 5. Quy tắc giả lập: Nếu email bắt đầu bằng "taken" (ví dụ: taken@gmail.com) -> Đã tồn tại!
    final email = _emailController.text.trim().toLowerCase();
    if (email.startsWith('taken')) {
      setState(() {
        _isCheckingEmail = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This email is already taken. Please try another!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 6. Hoàn tất đăng ký thành công
    setState(() {
      _isCheckingEmail = false;
    });
    _formKey.currentState!.save();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signup successful! Welcome to the app!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Signup'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // 1. Full Name
                  TextFormField(
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocus);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),

                  // 2. Email
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // 3. Password (Có mắt thần ẩn/hiện)
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'At least 8 chars & 1 digit',
                      prefixIcon: const Icon(Icons.lock),
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
                      border: const OutlineInputBorder(),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),

                  // 4. Confirm Password (Có mắt thần ẩn/hiện)
                  TextFormField(
                    focusNode: _confirmPasswordFocus,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_isCheckingEmail) {
                        _submitForm();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 24),

                  // 5. Submit Button (Có hiệu ứng Loading khi check Async)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    // Khóa nút bấm khi đang kiểm tra email
                    onPressed: _isCheckingEmail ? null : _submitForm,
                    child: _isCheckingEmail
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
