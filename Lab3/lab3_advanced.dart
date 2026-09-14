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

  print("\n--- KẾT THÚC LAB 3 ---");
}
