// ==========================================
// LAB 2: DART ESSENTIALS PRACTICE LAB
// ==========================================

import 'dart:async';

void main() async {
  print("--- BẮT ĐẦU LAB 2 ---\n");
  exercise1();
  print("--------------------\n");
  exercise2();
  print("--------------------\n");
  exercise3();
  print("--------------------\n");
  exercise4();
  print("--------------------\n");
  // Tính năng đợi (async/await) nên dùng await ở đây
  await exercise5();
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
  print("My GPA is $gpa. \nAm I a student? $isStudent.");

  // Tính toán trực tiếp trong chuỗi bằng ${}
  print("Next year, I will be ${age + 1} years old.");
}

// ------------------------------------------
// Exercise 2 – Collections & Operators
// ------------------------------------------
void exercise2() {
  print("Exercise 2: Collections & Operators");

  // 1. List (Danh sách có thứ tự, cho phép trùng lặp)
  List<int> numbers = [10, 20, 30];
  numbers.add(40); // Thêm 40
  numbers.remove(10); // Xoá 10
  print("List sau khi add và remove: $numbers");
  print("Phần tử đầu tiên: ${numbers[0]}");

  // 2. Set (Danh sách không có thứ tự, KHÔNG cho phép trùng lặp)
  // Do để trùng lặp nên IDE cũng cảnh báo
  Set<String> uniqueNames = {"Quan", "Binh", "Quan"};
  print("Set (loại bỏ phần tử trùng): $uniqueNames");

  // 3. Map (Lưu trữ theo cặp Khóa-Giá trị)
  Map<String, String> capitals = {
    "Vietnam": "Hanoi",
    "Japan": "Tokyo"
  };
  capitals["France"] = "Paris"; // Thêm cặp mới
  print("Thủ đô của Vietnam là: ${capitals["Vietnam"]}");

  // 4. Toán tử (Operators)
  int a = 5;
  int b = 10;

  // Toán tử 3 ngôi (? :)
  String result = (a < b && b == 10) ? "Điều kiện ĐÚNG" : "Điều kiện SAI";
  print("Toán tử 3 ngôi: $result");
}

// ------------------------------------------
// Exercise 3 – Control Flow & Functions
// ------------------------------------------
void exercise3() {
  print("Exercise 3: Control Flow & Functions");

  // 1. If/Else
  int score = 85;
  if (score >= 90) {
    print("Grade: A");
  } else if (score >= 80) {
    print("Grade: B");
  } else {
    print("Grade: C");
  }

  // 2. Switch case
  int day = 3;
  switch (day) {
    case 1: print("Monday"); break;
    case 3: print("Wednesday"); break;
    default: print("Other day");
  }

  // 3. Loops (Vòng lặp)
  List<String> fruits = ["Apple", "Banana", "Cherry"];

  // Vòng lặp For-in (Rất hay dùng trong Dart)
  for (String fruit in fruits) {
    print("For-in loop: $fruit");
  }

  // 4. Gọi hàm
  print("Kết quả hàm bình thường (5x4): ${multiply(5, 4)}");
  print("Kết quả hàm Arrow (10-3): ${subtract(10, 3)}");
}

// Hàm bình thường
int multiply(int x, int y) {
  return x * y;
}

// Hàm mũi tên (Arrow function) - Rút gọn cho hàm chỉ có 1 dòng return
int subtract(int x, int y) => x - y;

// ------------------------------------------
// Exercise 4 – Intro to OOP
// ------------------------------------------
class Car {
  String brand;

  // Constructor
  Car(this.brand);

  // Named Constructor (Constructor có tên riêng)
  Car.unknown() : brand = "Unknown Brand";

  void startEngine() {
    print("Car engine started: $brand");
  }
}

// Subclass kế thừa từ Car
class ElectricCar extends Car {
  int batteryCapacity;

  // Constructor gọi đến super() của lớp cha
  ElectricCar(String brand, this.batteryCapacity) : super(brand);

  // Ghi đè (override) hàm của lớp cha
  @override
  void startEngine() {
    print("Electric car ($brand) silently started with ${batteryCapacity}kWh battery.");
  }
}

void exercise4() {
  print("Exercise 4: Intro to OOP");

  Car myCar = Car("Toyota");
  myCar.startEngine();

  Car mysteriousCar = Car.unknown();
  mysteriousCar.startEngine();

  ElectricCar myTesla = ElectricCar("Tesla", 100);
  myTesla.startEngine();
}

// ------------------------------------------
// Exercise 5 – Async, Future, Null Safety & Streams
// ------------------------------------------
Future<void> exercise5() async {
  print("Exercise 5: Async, Future, Null Safety & Streams");

  // 1. Null Safety
  String? nullableString; // Dấu ? nghĩa là biến này có thể bị null

  // Toán tử ?? (Nếu bên trái null thì lấy chữ bên phải)
  String safeString = nullableString ?? "Giá trị mặc định";
  print("Null Safety test: $safeString");

  // 2. Async/Await & Future
  print("Đang tải dữ liệu mạng... (mô phỏng mất 2 giây)");
  String data = await fetchData();
  print("Dữ liệu nhận được: $data");

  // 3. Streams
  print("Bắt đầu nghe luồng dữ liệu (Stream):");
  Stream<int> numberStream = countNumbers();

  // Lắng nghe (listen) các giá trị được bắn ra từ Stream
  await for (int number in numberStream) {
    print("Stream nhận được số: $number");
  }
}

// Hàm mô phỏng tải dữ liệu mất thời gian (2 giây)
Future<String> fetchData() async {
  await Future.delayed(const Duration(seconds: 2));
  return "Dữ liệu từ máy chủ API";
}

// Hàm Stream mô phỏng bắn ra dữ liệu liên tục sau mỗi 1 giây
Stream<int> countNumbers() async* {
  for (int i = 1; i <= 3; i++) {
    await Future.delayed(const Duration(seconds: 1));
    yield i; // yield dùng để bắn dữ liệu ra liên tục
  }
}