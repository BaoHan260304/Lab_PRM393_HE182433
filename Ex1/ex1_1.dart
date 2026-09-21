// Ex1.1: Thiết kế hệ thống phương tiện giao thông

// TODO 1: Định nghĩa class Vehicle với các thuộc tính String brand, int year.
class Vehicle {
  String brand;
  int year;

  // Default constructor
  Vehicle(this.brand, this.year);

  // Hàm startEngine()
  void startEngine() {
    print("Khởi động phương tiện...");
  }
}

// TODO 2: Định nghĩa class Car kế thừa từ Vehicle.
class Car extends Vehicle {
  // Thêm thuộc tính bool isElectric.
  bool isElectric;

  // TODO 3: Viết constructor mặc định cho Car (dùng super để truyền brand và year).
  Car(String brand, int year, this.isElectric) : super(brand, year);

  // Viết Named Constructor: Car.tesla(int year) thiết lập sẵn brand="Tesla" và isElectric=true.
  Car.tesla(int year) : isElectric = true, super("Tesla", year);

  // TODO 4: Ghi đè (@override) hàm startEngine() để in ra thông báo chi tiết hơn.
  @override
  void startEngine() {
    if (isElectric) {
      print("Xe điện $brand ($year) khởi động êm ru: Vù vù...");
    } else {
      print("Xe xăng $brand ($year) khởi động ồn ào: Brum brum...");
    }
  }
}

void main() {
  print("=== BÀI 1.1: HỆ THỐNG GIAO THÔNG ===\n");
  
  // TODO 5: Khởi tạo một xe Car bình thường và gọi startEngine()
  Car myNormalCar = Car("Toyota", 2024, false);
  myNormalCar.startEngine();

  // TODO 6: Khởi tạo một xe Car bằng Named Constructor (Car.tesla) và gọi startEngine()
  Car myTesla = Car.tesla(2024);
  myTesla.startEngine();
}
