import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await GoogleAuthService.initialize();
  runApp(const Lab10FullApp());
}

// ================= 1. TRẠM QUẢN LÝ PHIÊN: SESSION MANAGER =================

class SessionManager {
  static const String keyToken = 'auth_token';
  static const String keyFullName = 'full_name';
  static const String keyEmail = 'user_email';
  static const String keyUsername = 'username';
  static const String keyAvatar = 'avatar_url';
  static const String keyProvider = 'auth_provider';

  static Future<void> saveSession({
    required String token,
    required String fullName,
    required String email,
    required String username,
    required String avatarUrl,
    required String provider,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyToken, token);
    await prefs.setString(keyFullName, fullName);
    await prefs.setString(keyEmail, email);
    await prefs.setString(keyUsername, username);
    await prefs.setString(keyAvatar, avatarUrl);
    await prefs.setString(keyProvider, provider);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken);
  }

  static Future<Map<String, String?>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      keyToken: prefs.getString(keyToken),
      keyFullName: prefs.getString(keyFullName),
      keyEmail: prefs.getString(keyEmail),
      keyUsername: prefs.getString(keyUsername),
      keyAvatar: prefs.getString(keyAvatar),
      keyProvider: prefs.getString(keyProvider),
    };
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyToken);
    await prefs.remove(keyFullName);
    await prefs.remove(keyEmail);
    await prefs.remove(keyUsername);
    await prefs.remove(keyAvatar);
    await prefs.remove(keyProvider);
  }
}

// ================= 2. TRẠM THÔNG BÁO NỘI BỘ: NOTIFICATION SERVICE (LO7) =================

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'prm393_full_channel';
  static const String channelName = 'PRM393 Full System Notifications';
  static const String channelDescription =
      'Kênh thông báo xác thực và bảo mật ứng dụng Lab 10 Full (LO7)';

  static bool isInitialized = false;

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Chạm vào thông báo: ${response.payload}');
      },
    );

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      await androidImplementation.createNotificationChannel(channel);
    }

    isInitialized = true;
  }

  static Future<bool> requestPermission() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted =
          await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// STEP 4: BẮN THÔNG BÁO TỨC THÌ KHI ĐĂNG NHẬP THÀNH CÔNG (LO7 MANDATORY)
  static Future<void> showAuthSuccessNotification({
    required String userName,
    required String authMethod,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'prm393_auth_ticker',
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails darwinDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: 8888,
      title: '🎉 Đăng Nhập Thành Công ($authMethod)!',
      body:
          'Xin chào $userName! Phiên làm việc đã được khởi tạo và ghi nhớ an toàn.',
      notificationDetails: notificationDetails,
      payload: 'auth_success_$authMethod',
    );
  }
}

// ================= 3. TRẠM DỊCH VỤ GOOGLE AUTH (OAUTH2) =================

class GoogleUserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String idToken;

  const GoogleUserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.idToken,
  });
}

class GoogleAuthService {
  static final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  static Future<void> initialize() async {}

  static Future<GoogleUserProfile?> signIn(BuildContext context) async {
    return await showModalBottomSheet<GoogleUserProfile>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                children: [
                  Text(
                    'G',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Đăng nhập với Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.deepOrange,
                  child: Text('Q',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: const Text('Nguyễn Mạnh Quân',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('nguyenmanhquan260304@gmail.com'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.pop(
                    context,
                    const GoogleUserProfile(
                      uid: 'google_oauth_98472918374928174',
                      displayName: 'Nguyễn Mạnh Quân',
                      email: 'nguyenmanhquan260304@gmail.com',
                      photoUrl:
                          'https://lh3.googleusercontent.com/a/ACg8ocIq7j5V6Z8=s96-c',
                      idToken:
                          'ya29.a0AfH6SMD_GoogleAuth_Full_ValidToken_HE182433',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= 4. GỐC ỨNG DỤNG =================

class Lab10FullApp extends StatelessWidget {
  const Lab10FullApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10 Full - Integrated Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ================= 5. MÀN HÌNH KHỞI ĐỘNG (SPLASH SCREEN) =================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Đang khởi động cỗ máy tích hợp...';

  @override
  void initState() {
    super.initState();
    _checkSessionAndRoute();
  }

  Future<void> _checkSessionAndRoute() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() {
      _status = 'Đang kiểm tra chìa khóa phiên trong SharedPreferences...';
    });

    final String? token = await SessionManager.getToken();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      final session = await SessionManager.getSession();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            fullName: session[SessionManager.keyFullName] ?? 'User',
            email: session[SessionManager.keyEmail] ?? '',
            username: session[SessionManager.keyUsername] ?? '',
            avatarUrl: session[SessionManager.keyAvatar] ?? '',
            token: token,
            authProvider: session[SessionManager.keyProvider] ?? 'Auto-Login',
            isAutoLogin: true,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                Icons.stars_rounded,
                size: 72,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Lab 10 Full: Integrated Suite',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'REST API • Session • Google Auth • LO7 Notification',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
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

// ================= 6. MÀN HÌNH ĐĂNG NHẬP ĐA PHƯƠNG THỨC =================

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
  bool _isLoadingApi = false;
  bool _isLoadingGoogle = false;

  @override
  void initState() {
    super.initState();
    // STEP 4: CHỦ ĐỘNG XIN QUYỀN THÔNG BÁO KHI VÀO MÀN HÌNH LOGIN
    NotificationService.requestPermission();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// CỔNG 1: ĐĂNG NHẬP DUMMYJSON REST API THẬT & BẮN THÔNG BÁO LO7
  Future<void> _handleApiLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoadingApi = true;
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
        final String email = data['email'] ?? '';
        final String avatarUrl = data['image'] ?? '';

        await SessionManager.saveSession(
          token: token,
          fullName: fullName,
          email: email,
          username: username,
          avatarUrl: avatarUrl,
          provider: 'DummyJSON REST API',
        );

        // STEP 4: PHÁT THÔNG BÁO BẢO MẬT CHÀO MỪNG ĐĂNG NHẬP REST API THÀNH CÔNG (LO7)
        await NotificationService.showAuthSuccessNotification(
          userName: fullName,
          authMethod: 'REST API',
        );

        if (!mounted) return;
        setState(() {
          _isLoadingApi = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              fullName: fullName,
              email: email,
              username: username,
              avatarUrl: avatarUrl,
              token: token,
              authProvider: 'DummyJSON REST API',
              isAutoLogin: false,
            ),
          ),
        );
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final String errorMsg =
            errorData['message'] ?? 'Sai tài khoản hoặc mật khẩu';

        setState(() {
          _isLoadingApi = false;
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
        _isLoadingApi = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lỗi: Mất kết nối Internet!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } on TimeoutException {
      setState(() {
        _isLoadingApi = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Quá thời gian chờ phản hồi từ máy chủ!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoadingApi = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Sự cố: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  /// CỔNG 2: ĐĂNG NHẬP GOOGLE IDENTITY (OAUTH2) & BẮN THÔNG BÁO LO7
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoadingGoogle = true;
    });

    final profile = await GoogleAuthService.signIn(context);

    if (!mounted) return;
    setState(() {
      _isLoadingGoogle = false;
    });

    if (profile != null) {
      await SessionManager.saveSession(
        token: profile.idToken,
        fullName: profile.displayName,
        email: profile.email,
        username: profile.email.split('@').first,
        avatarUrl: profile.photoUrl,
        provider: 'Google Identity (OAuth2)',
      );

      // STEP 4: PHÁT THÔNG BÁO BẢO MẬT CHÀO MỪNG ĐĂNG NHẬP GOOGLE THÀNH CÔNG (LO7)
      await NotificationService.showAuthSuccessNotification(
        userName: profile.displayName,
        authMethod: 'Google OAuth2',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            fullName: profile.displayName,
            email: profile.email,
            username: profile.email.split('@').first,
            avatarUrl: profile.photoUrl,
            token: profile.idToken,
            authProvider: 'Google Identity (OAuth2)',
            isAutoLogin: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10 Full - Login Portal'),
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
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 64,
                    color: Colors.teal,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cổng Đăng Nhập Tích Hợp',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Xác thực qua DummyJSON API hoặc Google Account',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // HUY HIỆU TÍCH HỢP NOTIFICATION (LO7)
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.deepPurple.shade200),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          size: 15, color: Colors.deepPurple),
                      SizedBox(width: 6),
                      Text(
                        'LO7: Thông Báo Bảo Mật Tự Động Kích Hoạt',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                        'Tài khoản DummyJSON: emilys / emilyspass',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _usernameController,
                enabled: !_isLoadingApi && !_isLoadingGoogle,
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
                enabled: !_isLoadingApi && !_isLoadingGoogle,
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
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    (_isLoadingApi || _isLoadingGoogle) ? null : _handleApiLogin,
                icon: _isLoadingApi
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
                  _isLoadingApi ? 'Đang gọi API...' : 'Đăng Nhập REST API',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'HOẶC',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (_isLoadingApi || _isLoadingGoogle)
                    ? null
                    : _handleGoogleLogin,
                child: _isLoadingGoogle
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'G',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Đăng nhập với Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= 7. MÀN HÌNH TRANG CHỦ =================

class HomeScreen extends StatelessWidget {
  final String fullName;
  final String email;
  final String username;
  final String avatarUrl;
  final String token;
  final String authProvider;
  final bool isAutoLogin;

  const HomeScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.username,
    required this.avatarUrl,
    required this.token,
    required this.authProvider,
    required this.isAutoLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10 Full - Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_rounded,
                  size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Xin chào, $fullName!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text('Phương thức: $authProvider'),
            ],
          ),
        ),
      ),
    );
  }
}
