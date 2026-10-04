import 'package:flutter/material.dart';
import 'movie_model.dart';

void main() {
  runApp(const ResponsiveMovieApp());
}

// Cầu dao tổng của hệ thống
class ResponsiveMovieApp extends StatelessWidget {
  const ResponsiveMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Movie UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GenreScreen(),
    );
  }
}

// Màn hình chính (Stateful vì lát nữa phải bấm lọc phim liên tục)
class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  // Biến lưu trữ từ khoá tìm kiếm (Step 4)
  String searchQuery = '';
  
  // Danh sách thể loại và giỏ chứa các thể loại đang được chọn (Step 5)
  final List<String> allGenres = ['Action', 'Comedy', 'Drama', 'Sci-Fi', 'Horror', 'Romance', 'Crime', 'Adventure'];
  Set<String> selectedGenres = {};

  // Tuỳ chọn sắp xếp và biến lưu trạng thái hiện tại (Step 6)
  final List<String> sortOptions = ['A-Z', 'Z-A', 'Year', 'Rating'];
  String selectedSort = 'A-Z';

  @override
  Widget build(BuildContext context) {
    // --- STEP 7: NÃO BỘ XỬ LÝ LOGIC (LỌC VÀ SẮP XẾP) ---
    // Khối code này được đặt ngay trong hàm build để mỗi lần gọi setState, 
    // App sẽ tự động chạy lại bộ lọc và trả ra danh sách phim mới nhất.
    
    List<Movie> visibleMovies = allMovies.where((movie) {
      // 1. Lọc theo chữ (Không phân biệt hoa thường)
      final matchesSearch = movie.title.toLowerCase().contains(searchQuery.toLowerCase());
      
      // 2. Lọc theo thể loại
      // Nếu giỏ trống -> Hợp lệ. Nếu có -> Phim phải chứa ít nhất 1 thể loại nằm trong giỏ.
      final matchesGenre = selectedGenres.isEmpty || 
          movie.genres.any((g) => selectedGenres.contains(g));
          
      return matchesSearch && matchesGenre;
    }).toList();

    // 3. Sắp xếp danh sách phim vừa lọc
    if (selectedSort == 'A-Z') {
      visibleMovies.sort((a, b) => a.title.compareTo(b.title));
    } else if (selectedSort == 'Z-A') {
      visibleMovies.sort((a, b) => b.title.compareTo(a.title));
    } else if (selectedSort == 'Year') {
      visibleMovies.sort((a, b) => b.year.compareTo(a.year)); // Phim cũ lên trước (có thể đảo b.year và a.year để phim mới lên trước)
    } else if (selectedSort == 'Rating') {
      visibleMovies.sort((a, b) => b.rating.compareTo(a.rating)); 
    }
    // ----------------------------------------------------

    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền hơi xám nhẹ cho sang
      // Khiên SafeArea giúp nội dung không bị lẹm vào camera tai thỏ
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề to chà bá
              const Text(
                'Find a Movie',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // ---------------------------------------------------------
              // CHỖ TRỐNG ĐỂ LÁT NỮA LẮP RÁP CÁC BỘ PHẬN Ở STEP SAU VÀO
              // ---------------------------------------------------------
              // --- STEP 4: THANH TÌM KIẾM (SEARCH BAR) ---
              TextField(
                onChanged: (value) {
                  // Gõ tới đâu, cập nhật biến tới đó để bắt giao diện vẽ lại
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Nhập tên phim cần tìm...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Bo góc tròn vo
                    borderSide: BorderSide.none, // Xoá viền đen
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // --- STEP 5: BẦY NÚT THỂ LOẠI (GENRE CHIPS) ---
              // Dùng bùa Wrap để nếu chật quá thì các nút tự động rớt xuống dòng dưới
              Wrap(
                spacing: 8.0, // Khoảng cách ngang giữa các nút
                runSpacing: 0.0, // Khoảng cách dọc khi rớt dòng
                children: allGenres.map((genre) {
                  final isSelected = selectedGenres.contains(genre); // Kiểm tra xem nút này có đang được chọn không
                  return FilterChip(
                    label: Text(genre),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple[100], // Màu nền khi được chọn
                    checkmarkColor: Colors.deepPurple, // Màu dấu tick
                    onSelected: (bool selected) {
                      // Bấm vào thì nhét vào giỏ, bỏ bấm thì lôi khỏi giỏ, và báo vẽ lại UI
                      setState(() {
                        if (selected) {
                          selectedGenres.add(genre);
                        } else {
                          selectedGenres.remove(genre);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              
              // --- STEP 6: NÚT SẮP XẾP (SORT DROPDOWN) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedSort, // Hiển thị giá trị đang được chọn
                    items: sortOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      // Bấm chọn sắp xếp kiểu mới thì cập nhật biến và vẽ lại UI
                      if (newValue != null) {
                        setState(() {
                          selectedSort = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.red[100],
                  child: const Center(child: Text('Danh sách phim sẽ hiển thị ở đây (Step 8) 🎬')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
