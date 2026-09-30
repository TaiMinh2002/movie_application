import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/errors.dart';
import '../../domain/entities/movie.dart';
import '../../domain/movie_repository.dart';
import '../datasources/movie_remote_ds.dart';

part 'movie_repository_impl.g.dart';

class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl(this._remote);

  final MovieRemoteDataSource _remote;

  @override
  Future<Result<MoviePage>> category(MovieCategory category, {int page = 1}) =>
      guard(() async => (await _remote.category(category, page)).toEntity());

  @override
  Future<Result<MoviePage>> discover({
    int? genreId,
    MovieSort sort = MovieSort.popularity,
    int page = 1,
  }) => guard(
    () async => (await _remote.discover(
      genreId: genreId,
      sort: sort,
      page: page,
    )).toEntity(),
  );

  @override
  Future<Result<MoviePage>> search(String query, {int page = 1}) =>
      guard(() async => (await _remote.search(query, page)).toEntity());

  @override
  Future<Result<List<Genre>>> genres() =>
      guard(() async => [for (final g in await _remote.genres()) g.toEntity()]);

  @override
  Future<Result<MovieDetail>> detail(int id) =>
      guard(() async => (await _remote.detail(id)).toEntity());
}

@Riverpod(keepAlive: true)
MovieRepository movieRepository(Ref ref) =>
    MovieRepositoryImpl(ref.watch(movieRemoteDataSourceProvider));
