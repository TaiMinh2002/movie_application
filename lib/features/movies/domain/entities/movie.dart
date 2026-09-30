class Genre {
  const Genre({required this.id, required this.name});
  final int id;
  final String name;
}

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.releaseDate,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;

  /// 0–10; 0 when TMDB has no votes yet.
  final double voteAverage;
  final DateTime? releaseDate;
}

class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  final int id;
  final String name;
  final String character;
  final String? profilePath;
}

class WatchProvider {
  const WatchProvider({required this.name, this.logoPath});
  final String name;
  final String? logoPath;
}

class MovieDetail {
  const MovieDetail({
    required this.movie,
    required this.genres,
    required this.cast,
    required this.similar,
    required this.providers,
    this.runtime,
    this.trailerKey,
  });

  final Movie movie;
  final List<Genre> genres;

  /// Minutes; null when TMDB doesn't know it.
  final int? runtime;
  final List<CastMember> cast;

  /// YouTube video key of the official trailer, if any.
  final String? trailerKey;
  final List<Movie> similar;

  /// Streaming services (flatrate) in `ApiConstants.watchRegion`.
  final List<WatchProvider> providers;
}

/// One page of a paginated TMDB list.
class MoviePage {
  const MoviePage({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  final List<Movie> items;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

enum MovieCategory { nowPlaying, popular, topRated, upcoming }

enum MovieSort { popularity, rating, releaseDate }
