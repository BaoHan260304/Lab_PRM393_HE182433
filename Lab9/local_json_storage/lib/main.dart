import 'package:flutter/material.dart';
import 'product_model.dart';
import 'storage_service.dart';

void main() {
  runApp(const LocalJsonStorageApp());
}

class LocalJsonStorageApp extends StatelessWidget {
  const LocalJsonStorageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local JSON Storage (Lab 9)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const StorageScreen(),
    );
  }
}

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final StorageService _storageService = StorageService();

  List<Product> _products = [];
  String _filePath = '';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDataFromStorage();
  }

  // ĐỌC DỮ LIỆU TỪ Ổ CỨNG KHI MỞ MÀN HÌNH (Lab 9.2)
  Future<void> _loadDataFromStorage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final path = await _storageService.getFilePath();
      final loadedList = await _storageService.loadProducts();

      setState(() {
        _filePath = path;
        _products = loadedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // THÊM SẢN PHẨM MẪU VÀO BỘ NHỚ TẠM
  void _addQuickProduct() {
    final newId = (_products.isEmpty ? 0 : _products.map((p) => p.id).reduce((a, b) => a > b ? a : b)) + 1;
    final newProduct = Product(
      id: newId,
      name: 'Món đồ mới #$newId',
      price: 99.0 + newId * 10,
      category: 'Gadgets',
      stock: 10,
    );

    setState(() {
      _products.add(newProduct);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm tạm "${newProduct.name}". Hãy nhấn "LƯU VÀO Ổ CỨNG" để lưu vĩnh viễn!'),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // GHI DANH SÁCH XUỐNG Ổ CỨNG THẬT CỦA THIẾT BỊ
  Future<void> _saveDataToStorage() async {
    try {
      await _storageService.saveProducts(_products);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💾 ĐÃ LƯU THÀNH CÔNG VÀO Ổ CỨNG! Tắt App bật lại dữ liệu vẫn còn.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi ghi file: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 9.2 - Device Storage'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Đọc lại từ ổ cứng',
            onPressed: _loadDataFromStorage,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 54, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_errorMessage, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDataFromStorage,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Bảng hiển thị đường dẫn file vật lý trên thiết bị
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.indigo.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.storage_rounded, size: 18, color: Colors.indigo),
                              SizedBox(width: 6),
                              Text(
                                'Vị trí file lưu trên ổ cứng thiết bị:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _filePath,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Danh sách sản phẩm hiện có
                    Expanded(
                      child: _products.isEmpty
                          ? const Center(child: Text('Danh sách trống.'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.indigo.shade100,
                                      child: Text(
                                        '#${product.id}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${product.category} • Còn ${product.stock} chiếc',
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                    ),
                                    trailing: Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Thanh nút bấm điều khiển
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _addQuickProduct,
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm sản phẩm'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _saveDataToStorage,
                              icon: const Icon(Icons.save),
                              label: const Text('Lưu vào Ổ cứng'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
