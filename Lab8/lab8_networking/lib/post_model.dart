class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  // HÀM KHỞI TẠO TIÊU CHUẨN
  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  // PHỄU ĐÚC DỮ LIỆU TỪ JSON (Factory Constructor)
  // Rót từng thuộc tính từ Map JSON vào khuôn mẫu của đối tượng Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  // HÀM CHUYỂN ĐỔI NGƯỢC THÀNH JSON (Dùng cho thao tác POST sau này)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };
  }
}
