import 'dart:async';
import 'dart:convert';

// ==========================================
// EXERCISE 1: Product Model & Repository
// ==========================================
class Product {
  final int id;
  final String name;
  final double price;

  Product(this.id, this.name, this.price);

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}

class ProductRepository {
  final List<Product> _products = [
    Product(1, 'Laptop', 999.9),
    Product(2, 'Phone', 599.9),
  ];

  // Phát sóng tới nhiều người nghe cùng lúc
  final StreamController<Product> _controller = StreamController<Product>.broadcast();

  Future<List<Product>> getAll() async {
    await Future.delayed(Duration(seconds: 1)); // Mô phỏng tải dữ liệu từ DB
    return _products;
  }

  Stream<Product> liveAdded() {
    return _controller.stream;
  }

  void addProduct(Product product) {
    _products.add(product);
    _controller.sink.add(product); // Phát sự kiện có sản phẩm mới
  }

  void dispose() {
    _controller.close();
  }
}

// ==========================================
// EXERCISE 2: User Repository with JSON
// ==========================================
class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  // Factory constructor để parse dữ liệu từ JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  @override
  String toString() => 'User(name: $name, email: $email)';
}

Future<List<User>> fetchUsersFromJson() async {
  // Chuỗi JSON mô phỏng trả về từ API
  String jsonString = '''
  [
    {"name": "Quan", "email": "quan@example.com"},
    {"name": "Binh", "email": "binh@example.com"}
  ]
  ''';

  await Future.delayed(Duration(seconds: 1)); // Mô phỏng độ trễ mạng
  List<dynamic> parsedList = jsonDecode(jsonString);
  return parsedList.map((json) => User.fromJson(json)).toList();
}

// ==========================================
// EXERCISE 3: Async + Microtask Debugging
// ==========================================
void runEventLoopDemo() {
  // Code đồng bộ chạy trước -> Microtask chạy thứ hai -> Future (Event Queue) chạy cuối cùng.

  // Future (Event Queue - Chạy sau cùng)
  Future(() => print("2. Future hoàn thành (Thuộc Event Queue - Rìa ngoài cùng)"));

  // Microtask (Ưu tiên cao hơn Event Queue)
  scheduleMicrotask(() => print("1. Microtask hoàn thành (Ưu tiên cắt hàng)"));

  print("0. Đồng bộ (Synchronous) chạy ngay lập tức");
}

// ==========================================
// MAIN
// ==========================================
void main() async {
  print("--- BẮT ĐẦU LAB 3 ---\n");

  print("=== EXERCISE 1: Product Model & Repository ===");
  final repo = ProductRepository();
  
  // Lắng nghe Stream ngay từ đầu
  repo.liveAdded().listen((product) {
    print("Stream : Vừa có sản phẩm mới được thêm -> $product");
  });

  print("Đang tải danh sách sản phẩm...");
  List<Product> products = await repo.getAll();
  print("Danh sách gốc: $products");
  
  // Kích hoạt thông báo Stream ở trên
  repo.addProduct(Product(3, 'Tablet', 299.9));
  
  // Chờ một xíu xiu cho stream in ra màn hình
  await Future.delayed(Duration(milliseconds: 50));

  print("\n=== EXERCISE 2: User Repository with JSON ===");
  List<User> users = await fetchUsersFromJson();
  for (var user in users) {
    print(user);
  }

  print("\n=== EXERCISE 3: Async + Microtask Debugging ===");
  runEventLoopDemo();
  // Đợi Event loop in xong trước khi chạy bài 4
  await Future.delayed(Duration(milliseconds: 100));

  print("\n--- KẾT THÚC LAB 3 ---");
}
