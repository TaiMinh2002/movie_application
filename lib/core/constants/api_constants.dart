abstract final class ApiConstants {
  static const tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  /// TMDB "API Read Access Token" from `--dart-define-from-file=tmdb.json`
  /// (gitignored; see tmdb.example.json).
  static const tmdbToken = String.fromEnvironment('TMDB_TOKEN');
  static const hasTmdb = tmdbToken != '';
}
