import 'package:flutter/material.dart';
import 'api_service.dart';
import 'post_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 8 - Networking & REST API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const PostListScreen(),
    );
  }
}

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _postsFuture;

  // Danh sách lưu trữ cục bộ để có thể chèn ngay bài viết mới vừa tạo vào đầu danh sách
  List<Post>? _cachedPosts;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  // TẢI DANH SÁCH BÀI VIẾT (GET Request)
  void _loadPosts() {
    setState(() {
      _cachedPosts = null; // Reset cache để FutureBuilder hiện vòng xoay
      _postsFuture = _apiService.getPosts().then((posts) {
        _cachedPosts = posts;
        return posts;
      });
    });
  }

  // VUỐT ĐỂ LÀM MỚI (Pull-to-refresh - Bonus Feature)
  Future<void> _refreshPosts() async {
    try {
      final posts = await _apiService.getPosts();
      setState(() {
        _cachedPosts = posts;
        _postsFuture = Future.value(posts);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật danh sách mới nhất!'),
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // HỘP THOẠI TẠO BÀI VIẾT MỚI (POST Request Dialog - Step 7 & Bonus)
  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.post_add, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text('Tạo bài viết mới (POST)'),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề bài viết',
                          hintText: 'Nhập tiêu đề...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: bodyController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung bài viết',
                          hintText: 'Nhập nội dung chi tiết...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập nội dung';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy bỏ'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() {
                            isSubmitting = true;
                          });

                          try {
                            // BẮN POST REQUEST LÊN MÁY CHỦ
                            final newPost = await _apiService.createPost(
                              title: titleController.text.trim(),
                              body: bodyController.text.trim(),
                            );

                            if (!mounted) return;
                            Navigator.of(dialogContext).pop();

                            // Chèn ngay bài viết mới vừa tạo vào đầu danh sách hiển thị
                            setState(() {
                              if (_cachedPosts != null) {
                                _cachedPosts!.insert(0, newPost);
                                _postsFuture = Future.value(_cachedPosts);
                              }
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🎉 Tạo bài viết thành công! (Mã ID: #${newPost.id})',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi tạo bài viết: $e'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Đăng bài'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (REST API Complete)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại bài viết',
            onPressed: _loadPosts,
          ),
        ],
      ),
      // NÚT BẤM NỔI TẠO BÀI VIẾT MỚI (POST Request)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tạo Post Mới'),
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          // 1. TRẠNG THÁI LOADING
          if (snapshot.connectionState == ConnectionState.waiting &&
              _cachedPosts == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Đang kết nối qua ApiService...',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 2. TRẠNG THÁI LỖI
          if (snapshot.hasError && _cachedPosts == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        size: 64,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rất tiếc! Đã có lỗi xảy ra',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _loadPosts,
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Thử lại ngay (Retry)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. TRẠNG THÁI DỮ LIỆU THÀNH CÔNG (Kèm tính năng vuốt để làm mới)
          final posts = _cachedPosts ?? snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(child: Text('Không có bài viết nào.'));
          }

          // VUỐT ĐỂ LÀM MỚI (RefreshIndicator)
          return RefreshIndicator(
            onRefresh: _refreshPosts,
            color: Colors.blueAccent,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: 80, // Để chừa khoảng trống cho FloatingActionButton
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final isNewlyCreated = post.id == 101; // ID mặc định khi tạo mới trên JsonPlaceholder

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: isNewlyCreated ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: isNewlyCreated
                        ? const BorderSide(color: Colors.green, width: 1.5)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isNewlyCreated
                          ? Colors.green.shade100
                          : Colors.blue.shade100,
                      child: Text(
                        '#${post.id}',
                        style: TextStyle(
                          color: isNewlyCreated ? Colors.green : Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            post.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isNewlyCreated)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'MỚI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
