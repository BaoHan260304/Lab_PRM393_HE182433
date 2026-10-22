import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const NotificationApp());
}

// ================= 1. TRẠM DỊCH VỤ THÔNG BÁO: NOTIFICATION SERVICE =================

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'prm393_auth_channel';
  static const String channelName = 'PRM393 Authentication Alerts';
  static const String channelDescription =
      'Kênh phát thông báo sau các thao tác xác thực quan trọng (LO7)';

  static bool isInitialized = false;

  /// Kênh lắng nghe phản hồi khi người dùng chạm vào thông báo từ thanh hệ thống
  static final ValueNotifier<String?> onNotificationPayload =
      ValueNotifier<String?>(null);

  /// Thiết lập flutter_local_notifications & Android Channel
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
        // Bắt sự kiện người dùng chạm vào thông báo trên thanh Notification Bar
        onNotificationPayload.value = response.payload;
        debugPrint('Hệ thống tiếp nhận tương tác thông báo: ${response.payload}');
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

  /// Xin quyền hiển thị thông báo
  static Future<bool> requestPermission() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted =
          await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    final iOSImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iOSImplementation != null) {
      final bool? granted = await iOSImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Phát thông báo tức thì
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'prm393_ticker',
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
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// STEP 5: HỦY / DỌN DẸP TOÀN BỘ THÔNG BÁO KHỎI THANH TRẠNG THÁI
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}

// ================= 2. GỐC ỨNG DỤNG =================

class NotificationApp extends StatelessWidget {
  const NotificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.5 - Local Notification (LO7)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotificationScreen(),
    );
  }
}

// ================= 3. MÀN HÌNH ĐIỀU KHIỂN & KIỂM CHỨNG HỆ THỐNG =================

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool? _isPermissionGranted;
  bool _isRequesting = false;
  bool _isTriggering = false;
  int _notificationCount = 0;
  final List<String> _verificationLogs = [];

  @override
  void initState() {
    super.initState();
    _verificationLogs.add('⚡ [Khởi tạo]: Notification Channel đã kích hoạt.');

    // STEP 5: LẮNG NGHE PHẢN HỒI KHI NGƯỜI DÙNG TƯƠNG TÁC VỚI THÔNG BÁO HỆ THỐNG
    NotificationService.onNotificationPayload.addListener(_onPayloadReceived);
  }

  @override
  void dispose() {
    NotificationService.onNotificationPayload
        .removeListener(_onPayloadReceived);
    super.dispose();
  }

  void _onPayloadReceived() {
    final payload = NotificationService.onNotificationPayload.value;
    if (payload != null && mounted) {
      setState(() {
        _verificationLogs.insert(
          0,
          '👆 [Chạm thông báo]: Hệ thống tiếp nhận payload: "$payload"',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📱 Đã mở thông báo từ thanh hệ thống: $payload'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  Future<void> _handleRequestPermission() async {
    setState(() {
      _isRequesting = true;
    });

    final bool granted = await NotificationService.requestPermission();

    if (!mounted) return;

    setState(() {
      _isPermissionGranted = granted;
      _isRequesting = false;
      _verificationLogs.insert(
        0,
        granted
            ? '✅ [Quyền hạn]: Hệ thống Android cấp quyền POST_NOTIFICATIONS.'
            : '❌ [Quyền hạn]: Người dùng từ chối cấp quyền thông báo.',
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              granted ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                granted
                    ? '✅ Đã cấp quyền thông báo thành công (POST_NOTIFICATIONS: Granted)!'
                    : '❌ Quyền thông báo bị từ chối hoặc chưa được cấp.',
              ),
            ),
          ],
        ),
        backgroundColor: granted ? Colors.green.shade700 : Colors.redAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleTriggerNotification() async {
    setState(() {
      _isTriggering = true;
    });

    _notificationCount++;
    final int notifId = 1000 + _notificationCount;
    final String notifTitle = '🔔 Thông Báo Mới: Xác Thực Thành Công!';
    final String notifBody =
        'Xin chào Nguyễn Mạnh Quân! Bạn vừa kích hoạt thông báo #$_notificationCount (LO7) của Lab 10.5.';
    final String notifPayload = 'payload_auth_success_$_notificationCount';

    await NotificationService.showNotification(
      id: notifId,
      title: notifTitle,
      body: notifBody,
      payload: notifPayload,
    );

    if (!mounted) return;

    setState(() {
      _isTriggering = false;
      _verificationLogs.insert(
        0,
        '🚀 [Đã phát]: Thông báo #$_notificationCount (ID: $notifId) gửi tới System Tray.',
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '🚀 Đã phát thông báo #$_notificationCount! Kiểm tra thanh thông báo đỉnh màn hình.',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// STEP 5: DỌN SẠCH CÁC THÔNG BÁO ĐANG HIỂN THỊ
  Future<void> _handleCancelAll() async {
    await NotificationService.cancelAll();
    if (!mounted) return;

    setState(() {
      _verificationLogs.insert(
        0,
        '🧹 [Dọn dẹp]: Đã xóa sạch tất cả thông báo khỏi thanh trạng thái.',
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã dọn sạch thông báo khỏi thanh trạng thái!'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10.5 - Local Notification'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Xóa sạch thông báo',
            icon: const Icon(Icons.clear_all_rounded),
            onPressed: _handleCancelAll,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  size: 64,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Local Notification (LO7)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Tích hợp và kiểm chứng thông báo đẩy cục bộ trên Android/iOS',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // THẺ CẤU HÌNH KÊNH THÔNG BÁO
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.deepPurple.shade200),
              ),
              color: Colors.deepPurple.shade50.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings_suggest_rounded,
                            color: Colors.deepPurple.shade800, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Cấu hình flutter_local_notifications',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.deepPurple.shade900,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Text(
                      '📡 Channel: ${NotificationService.channelId} • Max Importance (Banner + Rung + Chuông)',
                      style: const TextStyle(fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // THẺ TRẠNG THÁI QUYỀN
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _isPermissionGranted == true
                      ? Colors.green.shade300
                      : (_isPermissionGranted == false
                          ? Colors.red.shade300
                          : Colors.amber.shade300),
                ),
              ),
              color: _isPermissionGranted == true
                  ? Colors.green.shade50.withValues(alpha: 0.5)
                  : (_isPermissionGranted == false
                      ? Colors.red.shade50.withValues(alpha: 0.5)
                      : Colors.amber.shade50.withValues(alpha: 0.5)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Icon(
                      _isPermissionGranted == true
                          ? Icons.verified_rounded
                          : (_isPermissionGranted == false
                              ? Icons.gpp_bad_rounded
                              : Icons.security_rounded),
                      color: _isPermissionGranted == true
                          ? Colors.green.shade700
                          : (_isPermissionGranted == false
                              ? Colors.redAccent
                              : Colors.amber.shade800),
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isPermissionGranted == true
                            ? '🟢 Quyền Android 13+: ĐÃ ĐƯỢC CẤP (Granted)'
                            : (_isPermissionGranted == false
                                ? '🔴 Quyền Android 13+: BỊ TỪ CHỐI (Denied)'
                                : '🟡 Quyền Android 13+: CHƯA CẤP'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isPermissionGranted == true
                              ? Colors.green.shade900
                              : (_isPermissionGranted == false
                                  ? Colors.red.shade900
                                  : Colors.amber.shade900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // NÚT BƯỚC 1: XIN QUYỀN HỆ THỐNG
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isRequesting ? null : _handleRequestPermission,
              icon: _isRequesting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.security_update_good_rounded),
              label: const Text(
                '1. Yêu Cầu Cấp Quyền Thông Báo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // NÚT BƯỚC 2: BẮN THÔNG BÁO THỦ CÔNG
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isTriggering ? null : _handleTriggerNotification,
              icon: _isTriggering
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.notification_add_rounded),
              label: Text(
                _isTriggering
                    ? 'Đang phát thông báo...'
                    : '2. Kích Hoạt Bắn Thông Báo Thử Nghiệm',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // STEP 5: HỘP KIỂM CHỨNG HỆ THỐNG (SYSTEM VERIFICATION LOGS)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.terminal_rounded,
                                color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              'Nhật ký kiểm chứng hệ thống (LO7):',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Text(
                          '${_verificationLogs.length} sự kiện',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 130,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        itemCount: _verificationLogs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              _verificationLogs[index],
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: Colors.greenAccent,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '⚡ Vuốt thanh trạng thái đỉnh màn hình xuống hoặc chạm vào thông báo để kiểm chứng phản hồi hệ thống.',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
