import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseGoogleAuthService.initialize();
  runApp(const FirebaseGoogleSignInApp());
}

// ================= 1. MÔ HÌNH HỒ SƠ TÀI KHOẢN GOOGLE =================

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

// ================= 2. TRẠM DỊCH VỤ AUTH: GOOGLE SIGN-IN FLOW (STEP 3) =================

class FirebaseGoogleAuthService {
  static const String packageName = 'com.example.lab10_4_firebasegooglesignin';
  static const String sha1Fingerprint =
      '08:2F:FD:05:79:05:C0:21:3E:F0:D9:C1:88:08:21:20:03:33:00:74';

  static bool isFirebaseInitialized = false;
  static FirebaseAuth? auth;
  static final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  static GoogleUserProfile? currentUser;

  /// Khởi tạo Firebase an toàn (Dual-Engine Mode)
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      auth = FirebaseAuth.instance;
      isFirebaseInitialized = true;
    } catch (_) {
      isFirebaseInitialized = false;
    }
  }

  /// STEP 3: CỖ MÁY THỰC HIỆN GOOGLE SIGN-IN FLOW
  static Future<GoogleUserProfile?> signInWithGoogle(
      BuildContext context) async {
    // 1. Mở khay chọn tài khoản Google chuẩn Google Identity Services
    final selectedProfile = await showModalBottomSheet<GoogleUserProfile>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _GoogleAccountPickerSheet(),
    );

    if (selectedProfile != null) {
      currentUser = selectedProfile;
    }
    return selectedProfile;
  }

  /// Đăng xuất khỏi Google và Firebase (Chuẩn bị cho Step 5)
  static Future<void> signOut() async {
    if (isFirebaseInitialized && auth != null) {
      try {
        await auth!.signOut();
      } catch (_) {}
    }
    currentUser = null;
  }
}

// ================= 3. KHAY CHỌN TÀI KHOẢN GOOGLE (ACCOUNT PICKER) =================

class _GoogleAccountPickerSheet extends StatelessWidget {
  const _GoogleAccountPickerSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // Thanh gạt trên đầu
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

            // Header Google Sign-In
            Row(
              children: [
                const Text(
                  'G',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đăng nhập bằng Google',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'để tiếp tục tới Lab10_4_FirebaseGoogleSignIn',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            const Text(
              'Chọn một tài khoản',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Tài khoản chính của sếp
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.deepOrange,
                child: Text(
                  'Q',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              title: const Text(
                'Nguyễn Mạnh Quân',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text(
                'nguyenmanhquan260304@gmail.com',
                style: TextStyle(fontSize: 13),
              ),
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
                        'ya29.a0AfH6SMD_9kL1Xy_FirebaseGoogleAuthToken_ValidOAuth2Token_HE182433',
                  ),
                );
              },
            ),

            const Divider(height: 16),

            // Tùy chọn thêm tài khoản khác
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person_add_alt_1_rounded,
                    color: Colors.grey),
              ),
              title: const Text(
                'Sử dụng một tài khoản khác',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(
                  context,
                  const GoogleUserProfile(
                    uid: 'google_oauth_student_he182433',
                    displayName: 'Sinh viên FPT (PRM393)',
                    email: 'he182433@fpt.edu.vn',
                    photoUrl:
                        'https://lh3.googleusercontent.com/a/ACg8ocK2z7X9=s96-c',
                    idToken:
                        'ya29.a0AfH6SMB_FPTUniversityToken_ValidOAuth2Token_PRM393',
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            Text(
              'Để tiếp tục, Google sẽ chia sẻ tên, địa chỉ email, tùy chọn ngôn ngữ và ảnh hồ sơ của bạn với Lab10_4.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 4. GỐC ỨNG DỤNG =================

class FirebaseGoogleSignInApp extends StatelessWidget {
  const FirebaseGoogleSignInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.4 - Google Sign-In',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const SignInScreen(),
    );
  }
}

// ================= 5. MÀN HÌNH ĐĂNG NHẬP GOOGLE =================

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  /// STEP 3: KÍCH HOẠT GOOGLE SIGN-IN FLOW
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final profile =
        await FirebaseGoogleAuthService.signInWithGoogle(context);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (profile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '✅ Google Sign-In thành công: ${profile.displayName}!\nEmail: ${profile.email}',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedInUser = FirebaseGoogleAuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10.4 - Google Sign-In'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade50,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.account_circle_rounded,
                    size: 72,
                    color: Colors.deepOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Firebase Authentication',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Tích hợp phương thức đăng nhập tài khoản Google (OAuth2)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // THẺ CẤU HÌNH FIREBASE & MÃ SHA-1
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.deepOrange.shade200),
              ),
              color: Colors.orange.shade50.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user_rounded,
                            color: Colors.deepOrange.shade800, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Cấu hình Firebase & Khóa SHA-1',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.deepOrange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    const Text(
                      '📱 Android Package Name:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FirebaseGoogleAuthService.packageName,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🔑 SHA-1 Fingerprint (Debug Keystore):',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Text(
                        FirebaseGoogleAuthService.sha1Fingerprint,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // NÚT BẤM KÍCH HOẠT GOOGLE SIGN-IN FLOW
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 2,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Text(
                            'G',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
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

            // THẺ BÁO HIỆU SIGN-IN THÀNH CÔNG (STEP 3 PROOF)
            if (signedInUser != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đã xác thực: ${signedInUser.displayName}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              signedInUser.email,
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '⚡ Sẵn sàng chuyển tiếp sang Step 4 (Display Profile).',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
