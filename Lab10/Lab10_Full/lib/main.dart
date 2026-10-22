import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  static Future<void> initialize() async {
    // Sẵn sàng dịch vụ Google Sign-In
  }

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

// ================= 5. MÀN HÌNH KHỞI ĐỘNG (STEP 2: SPLASH SCREEN ROUTING) =================

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
      // Đã có Token -> Auto-login thẳng vào HomeScreen
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
      // Chưa có phiên -> Vào LoginScreen
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

// ================= 6. MÀN HÌNH ĐĂNG NHẬP KHUNG XƯƠNG =================

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10 Full - Login Portal'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_open_rounded, size: 64, color: Colors.teal),
            SizedBox(height: 16),
            Text(
              'Trạm Đăng Nhập Sẵn Sàng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Sẵn sàng lắp ráp DummyJSON API & Google Sign-In ở Step 3',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 7. MÀN HÌNH TRANG CHỦ KHUNG XƯƠNG =================

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
            Text('Định tuyến thành công qua $authProvider'),
          ],
        ),
      ),
    );
  }
}
