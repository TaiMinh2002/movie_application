import '../../../core/error/errors.dart';
import 'entities/movie.dart';

abstract class MovieRepository {
  Future<Result<MoviePage>> category(MovieCategory category, {int page = 1});

  Future<Result<MoviePage>> discover({
    int? genreId,
    MovieSort sort = MovieSort.popularity,
    int page = 1,
  });

  Future<Result<MoviePage>> search(String query, {int page = 1});

  Future<Result<List<Genre>>> genres();

  Future<Result<MovieDetail>> detail(int id);
}
