class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final String overview;
  final double rating;
  final List<String> genres;
  final List<String> trailers;

  // Khuôn đúc bắt buộc phải truyền đủ thông số
  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.overview,
    required this.rating,
    required this.genres,
    required this.trailers,
  });
}

// ----------------------------------------------------
// DỮ LIỆU GIẢ (DUMMY DATA) THAY THẾ CHO API MẠNG
// ----------------------------------------------------
final List<Movie> sampleMovies = [
  Movie(
    id: '1',
    title: 'Interstellar',
    posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QlsEOWepVNzMU5cR8ZqO4fS.jpg',
    overview: 'Một nhóm thám hiểm vũ trụ du hành qua một lỗ sâu (wormhole) để tìm kiếm một hành tinh mới có thể duy trì sự sống cho nhân loại.',
    rating: 8.6,
    genres: ['Sci-Fi', 'Adventure', 'Drama'],
    trailers: ['Trailer 1: Khởi hành', 'Trailer 2: Hố đen'],
  ),
  Movie(
    id: '2',
    title: 'Inception',
    posterUrl: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
    overview: 'Một kẻ trộm có khả năng đi vào giấc mơ của người khác để đánh cắp bí mật, nay phải thực hiện một nhiệm vụ cấy ghép ý tưởng.',
    rating: 8.8,
    genres: ['Action', 'Sci-Fi', 'Thriller'],
    trailers: ['Trailer 1: Giấc mơ', 'Trailer 2: Trọng lực'],
  ),
  Movie(
    id: '3',
    title: 'The Dark Knight',
    posterUrl: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
    overview: 'Người Dơi phải đối mặt với một tên tội phạm điên loạn có biệt danh là The Joker, kẻ muốn nhấn chìm thành phố Gotham trong hỗn loạn.',
    rating: 9.0,
    genres: ['Action', 'Crime', 'Drama'],
    trailers: ['Trailer 1: Kỵ sĩ bóng đêm', 'Trailer 2: Trò đùa'],
  ),
];
