import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirebaseGoogleSignInApp());
}

class FirebaseGoogleSignInApp extends StatelessWidget {
  const FirebaseGoogleSignInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.4 - Firebase Google Sign-In',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.g_mobiledata_rounded, size: 84, color: Colors.deepOrange),
              SizedBox(height: 16),
              Text(
                'Lab 10.4 - Google Sign-In',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Step 1: Khởi tạo dự án & Cài đặt gói Firebase',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
