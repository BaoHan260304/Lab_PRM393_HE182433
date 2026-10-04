class Movie {
  final String title;
  final int year;
  final List<String> genres;
  final String posterUrl;
  final double rating;

  // Khuôn đúc bắt buộc phải truyền đủ 5 thông số
  Movie({
    required this.title,
    required this.year,
    required this.genres,
    required this.posterUrl,
    required this.rating,
  });
}

// Kho dữ liệu phim giả (Dummy Data) để test tính năng Lọc
final List<Movie> allMovies = [
  Movie(
    title: 'Inception',
    year: 2010,
    genres: ['Action', 'Sci-Fi'],
    posterUrl: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
    rating: 8.8,
  ),
  Movie(
    title: 'The Dark Knight',
    year: 2008,
    genres: ['Action', 'Crime', 'Drama'],
    posterUrl: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
    rating: 9.0,
  ),
  Movie(
    title: 'Interstellar',
    year: 2014,
    genres: ['Adventure', 'Drama', 'Sci-Fi'],
    posterUrl: 'https://placehold.co/400x600/292929/FFFFFF/png?text=Interstellar',
    rating: 8.6,
  ),
  Movie(
    title: 'The Hangover',
    year: 2009,
    genres: ['Comedy'],
    posterUrl: 'https://placehold.co/400x600/292929/FFFFFF/png?text=The+Hangover',
    rating: 7.7,
  ),
  Movie(
    title: 'Titanic',
    year: 1997,
    genres: ['Drama', 'Romance'],
    posterUrl: 'https://image.tmdb.org/t/p/w500/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg',
    rating: 7.9,
  ),
  Movie(
    title: 'Avengers: Endgame',
    year: 2019,
    genres: ['Action', 'Adventure', 'Sci-Fi'],
    posterUrl: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
    rating: 8.4,
  ),
];
