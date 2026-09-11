// ==========================================
// LAB 2: DART ESSENTIALS PRACTICE LAB
// ==========================================

import 'dart:async';

void main() async {
  print("--- BẮT ĐẦU LAB 2 ---\n");
  exercise1();
  print("--------------------\n");
  print("\n--- KẾT THÚC LAB 2 ---");
}

// ------------------------------------------
// Exercise 1 – Basic Syntax & Data Types
// ------------------------------------------
void exercise1() {
  print("Exercise 1: Basic Syntax & Data Types");

  // Khai báo các biến cơ bản
  int age = 22;
  double gpa = 3.8;
  String name = "Quan";
  bool isStudent = true;

  // Sử dụng String interpolation (chèn biến trực tiếp vào chuỗi bằng dấu $)
  print("My name is $name, I am $age years old.");
  print("My GPA is $gpa. Am I a student? $isStudent.");

  // Tính toán trực tiếp trong chuỗi bằng ${}
  print("Next year, I will be ${age + 1} years old.");
}

