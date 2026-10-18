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
      title: 'Local JSON Mini Database (Lab 9)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CrudDatabaseScreen(),
    );
  }
}

class CrudDatabaseScreen extends StatefulWidget {
  const CrudDatabaseScreen({super.key});

  @override
  State<CrudDatabaseScreen> createState() => _CrudDatabaseScreenState();
}

class _CrudDatabaseScreenState extends State<CrudDatabaseScreen> {
  final StorageService _storageService = StorageService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 1. TẢI DỮ LIỆU TỪ Ổ CỨNG (READ)
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final list = await _storageService.loadProducts();
      setState(() {
        _products = list;
        _filterProducts();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // 2. TÌM KIẾM THEO TỪ KHÓA THỜI GIAN THỰC (SEARCH)
  void _onSearchChanged() {
    _filterProducts();
  }

  void _filterProducts() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        _filteredProducts = _products.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // 3. TỰ ĐỘNG GHI Ổ CỨNG SAU MỖI THAO TÁC (AUTO-SAVE)
  Future<void> _autoSaveAndNotify(String actionMessage) async {
    try {
      await _storageService.saveProducts(_products);
      _filterProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('💾 $actionMessage (Đã tự động lưu vào ổ cứng)'),
            backgroundColor: Colors.indigo,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tự động lưu: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // 4. HỘP THOẠI THÊM / SỬA SẢN PHẨM (CREATE & UPDATE)
  void _showProductDialog({Product? existingProduct}) {
    final isEditing = existingProduct != null;
    final nameController = TextEditingController(text: existingProduct?.name ?? '');
    final priceController =
        TextEditingController(text: existingProduct != null ? existingProduct.price.toString() : '');
    final categoryController =
        TextEditingController(text: existingProduct?.category ?? 'General');
    final stockController =
        TextEditingController(text: existingProduct != null ? existingProduct.stock.toString() : '10');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                color: Colors.indigo,
              ),
              const SizedBox(width: 8),
              Text(isEditing ? 'Sửa sản phẩm #${existingProduct.id}' : 'Thêm sản phẩm mới'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên sản phẩm',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Giá (\$)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || double.tryParse(v) == null ? 'Giá hợp lệ' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Số lượng',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || int.tryParse(v) == null ? 'Số lượng' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục (Category)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final name = nameController.text.trim();
                final price = double.parse(priceController.text.trim());
                final category = categoryController.text.trim().isEmpty
                    ? 'General'
                    : categoryController.text.trim();
                final stock = int.parse(stockController.text.trim());

                if (isEditing) {
                  // CẬP NHẬT (UPDATE)
                  final index = _products.indexWhere((p) => p.id == existingProduct.id);
                  if (index != -1) {
                    _products[index] = existingProduct.copyWith(
                      name: name,
                      price: price,
                      category: category,
                      stock: stock,
                    );
                    _autoSaveAndNotify('Đã cập nhật "${existingProduct.name}"');
                  }
                } else {
                  // TẠO MỚI (CREATE - TỰ TĂNG ID)
                  final nextId = (_products.isEmpty
                          ? 0
                          : _products.map((p) => p.id).reduce((a, b) => a > b ? a : b)) +
                      1;
                  final newProduct = Product(
                    id: nextId,
                    name: name,
                    price: price,
                    category: category,
                    stock: stock,
                  );
                  _products.insert(0, newProduct);
                  _autoSaveAndNotify('Đã thêm mới "${newProduct.name}"');
                }

                Navigator.of(dialogContext).pop();
              },
              child: Text(isEditing ? 'Lưu thay đổi' : 'Thêm ngay'),
            ),
          ],
        );
      },
    );
  }

  // 5. HỘP THOẠI XÁC NHẬN XÓA AN TOÀN (DELETE WITH CONFIRMATION)
  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Xác nhận xóa'),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa vĩnh viễn sản phẩm "${product.name}" khỏi ổ cứng?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy bỏ'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _products.removeWhere((p) => p.id == product.id);
                });
                _autoSaveAndNotify('Đã xóa vĩnh viễn "${product.name}"');
              },
              child: const Text('Xóa ngay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tính tổng giá trị kho hàng
    final totalInventoryValue =
        _products.fold<double>(0, (sum, item) => sum + (item.price * item.stock));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Local JSON Mini Database (Lab 9.3)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Nạp lại',
            onPressed: _loadData,
          ),
        ],
      ),
      // NÚT BẤM NỔI THÊM SẢN PHẨM MỚI (CREATE)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm Sản Phẩm'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 54, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // A. THANH TÌM KIẾM (SEARCH BAR)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      color: Colors.white,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm theo tên hoặc danh mục...',
                          prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // B. THẺ THỐNG KÊ KHO HÀNG (DASHBOARD STATS)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  size: 16, color: Colors.indigo),
                              const SizedBox(width: 4),
                              Text(
                                'Mặt hàng: ${_filteredProducts.length}/${_products.length}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.attach_money, size: 16, color: Colors.green),
                              Text(
                                'Tổng giá trị: \$${totalInventoryValue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // C. DANH SÁCH SẢN PHẨM (READ, UPDATE, DELETE)
                    Expanded(
                      child: _filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 54, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    _products.isEmpty
                                        ? 'Kho hàng hiện đang trống.\nHãy bấm nút bên dưới để thêm!'
                                        : 'Không tìm thấy sản phẩm phù hợp.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                top: 8,
                                bottom: 80, // Để chừa chỗ cho FloatingActionButton
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // TẦNG 1: ID + TÊN (EXPANDED CHỐNG TRÀN) + GIÁ TIỀN
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: Colors.indigo.shade100,
                                              child: Text(
                                                '#${product.id}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.indigo,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                product.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '\$${product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // TẦNG 2: DANH MỤC + TỒN KHO + CẶP NÚT SỬA/XÓA
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.indigo.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                product.category,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.indigo,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Kho: ${product.stock} chiếc',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const Spacer(),
                                            // NÚT CHỈNH SỬA (UPDATE)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                                color: Colors.blueAccent,
                                              ),
                                              tooltip: 'Chỉnh sửa',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () =>
                                                  _showProductDialog(existingProduct: product),
                                            ),
                                            const SizedBox(width: 16),
                                            // NÚT XÓA (DELETE)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 20,
                                                color: Colors.redAccent,
                                              ),
                                              tooltip: 'Xóa',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () => _confirmDelete(product),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
