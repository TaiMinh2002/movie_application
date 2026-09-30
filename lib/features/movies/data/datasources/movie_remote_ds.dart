import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/movie.dart';
import '../models/movie_dto.dart';

part 'movie_remote_ds.g.dart';

class MovieRemoteDataSource {
  const MovieRemoteDataSource(this._dio);

  final Dio _dio;

  Future<T> _get<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Map<String, Object?> query = const {},
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
      );
      return parse(res.data!);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  Future<MoviePageDto> category(MovieCategory category, int page) {
    final path = switch (category) {
      MovieCategory.nowPlaying => 'now_playing',
      MovieCategory.popular => 'popular',
      MovieCategory.topRated => 'top_rated',
      MovieCategory.upcoming => 'upcoming',
    };
    return _get('/movie/$path', MoviePageDto.fromJson, query: {'page': page});
  }

  Future<MoviePageDto> discover({
    int? genreId,
    required MovieSort sort,
    required int page,
  }) => _get(
    '/discover/movie',
    MoviePageDto.fromJson,
    query: {
      'page': page,
      'sort_by': switch (sort) {
        MovieSort.popularity => 'popularity.desc',
        MovieSort.rating => 'vote_average.desc',
        MovieSort.releaseDate => 'primary_release_date.desc',
      },
      'with_genres': ?genreId,
      // Without a vote floor, rating order is topped by films with one vote.
      if (sort == MovieSort.rating) 'vote_count.gte': 200,
    },
  );

  Future<MoviePageDto> search(String query, int page) => _get(
    '/search/movie',
    MoviePageDto.fromJson,
    query: {'query': query, 'page': page},
  );

  Future<List<GenreDto>> genres() => _get(
    '/genre/movie/list',
    (json) => [
      for (final g in json['genres'] as List)
        GenreDto.fromJson(g as Map<String, dynamic>),
    ],
  );

  Future<MovieDetailDto> detail(int id) => _get(
    '/movie/$id',
    MovieDetailDto.fromJson,
    query: {'append_to_response': 'credits,videos,similar,watch/providers'},
  );
}

@Riverpod(keepAlive: true)
MovieRemoteDataSource movieRemoteDataSource(Ref ref) =>
    MovieRemoteDataSource(ref.watch(dioProvider));
