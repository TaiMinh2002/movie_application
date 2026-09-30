import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_application/core/error/errors.dart';
import 'package:movie_application/features/movies/data/datasources/movie_remote_ds.dart';
import 'package:movie_application/features/movies/data/models/movie_dto.dart';
import 'package:movie_application/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movie_application/features/movies/domain/entities/movie.dart';

class _MockRemote extends Mock implements MovieRemoteDataSource {}

/// Answers every request with [json] and records the last request.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.json);
  final String json;
  late RequestOptions last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      json,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _detailJson = '''
{
  "id": 1, "title": "Dune", "overview": "Sand", "poster_path": "/p.jpg",
  "backdrop_path": null, "vote_average": 8.1, "release_date": "",
  "runtime": 155,
  "genres": [{"id": 12, "name": "Adventure"}],
  "credits": {"cast": [{"id": 7, "name": "Zendaya", "character": "Chani", "profile_path": null}]},
  "videos": {"results": [
    {"key": "teaser", "site": "YouTube", "type": "Teaser"},
    {"key": "vimeo1", "site": "Vimeo", "type": "Trailer"},
    {"key": "trailer", "site": "YouTube", "type": "Trailer"}
  ]},
  "similar": {"results": [{"id": 2, "title": "Dune 2"}]},
  "watch/providers": {"results": {
    "VN": {"flatrate": [{"provider_name": "Netflix", "logo_path": "/n.jpg"}]},
    "US": {"flatrate": [{"provider_name": "Max"}]}
  }}
}
''';

void main() {
  group('DTO mapping', () {
    test('movie: empty release date becomes null, missing fields default', () {
      final movie = MovieDto.fromJson({
        'id': 1,
        'title': 'A',
        'release_date': '',
      }).toEntity();

      expect(movie.releaseDate, isNull);
      expect(movie.overview, '');
      expect(movie.voteAverage, 0);
      expect(movie.posterPath, isNull);
    });

    test('page: hasMore is false on the last page', () {
      MoviePage page(int n) => MoviePageDto.fromJson({
        'page': n,
        'total_pages': 3,
        'results': [
          {'id': 1, 'title': 'A'},
        ],
      }).toEntity();

      expect(page(2).hasMore, isTrue);
      expect(page(3).hasMore, isFalse);
    });

    test('detail: flattens appended responses for the configured region', () {
      final d = MovieDetailDto.fromJson(_decode(_detailJson)).toEntity();

      expect(d.movie.title, 'Dune');
      expect(d.runtime, 155);
      expect(d.genres.single.name, 'Adventure');
      expect(d.cast.single.character, 'Chani');
      expect(d.similar.single.title, 'Dune 2');
      expect(d.providers.map((p) => p.name), ['Netflix']);
    });

    test('detail: picks the YouTube trailer, else any YouTube video', () {
      final d = MovieDetailDto.fromJson(_decode(_detailJson)).toEntity();
      expect(d.trailerKey, 'trailer');

      final noTrailer = MovieDetailDto.fromJson({
        'id': 1,
        'title': 'A',
        'videos': {
          'results': [
            {'key': 'teaser', 'site': 'YouTube', 'type': 'Teaser'},
          ],
        },
      }).toEntity();
      expect(noTrailer.trailerKey, 'teaser');
    });

    test('detail: tolerates missing appended sections', () {
      final d = MovieDetailDto.fromJson({'id': 1, 'title': 'A'}).toEntity();

      expect(d.cast, isEmpty);
      expect(d.providers, isEmpty);
      expect(d.trailerKey, isNull);
    });
  });

  group('MovieRemoteDataSource', () {
    (MovieRemoteDataSource, _StubAdapter) setup(String json) {
      final adapter = _StubAdapter(json);
      final dio = Dio(BaseOptions(baseUrl: 'https://x.test'))
        ..httpClientAdapter = adapter;
      return (MovieRemoteDataSource(dio), adapter);
    }

    test('discover by rating adds a vote floor and the genre', () async {
      final (ds, adapter) = setup('{"page":1,"total_pages":1,"results":[]}');
      await ds.discover(genreId: 28, sort: MovieSort.rating, page: 2);

      expect(adapter.last.path, '/discover/movie');
      expect(adapter.last.queryParameters, {
        'page': 2,
        'sort_by': 'vote_average.desc',
        'with_genres': 28,
        'vote_count.gte': 200,
      });
    });

    test('detail appends credits, videos, similar and providers', () async {
      final (ds, adapter) = setup(_detailJson);
      final dto = await ds.detail(1);

      expect(adapter.last.path, '/movie/1');
      expect(
        adapter.last.queryParameters['append_to_response'],
        'credits,videos,similar,watch/providers',
      );
      expect(dto.movie.title, 'Dune');
    });
  });

  group('MovieRepositoryImpl', () {
    late _MockRemote remote;
    late MovieRepositoryImpl repo;

    setUp(() {
      remote = _MockRemote();
      repo = MovieRepositoryImpl(remote);
    });

    test('returns Ok with mapped entities', () async {
      when(() => remote.category(MovieCategory.popular, 1)).thenAnswer(
        (_) async => const MoviePageDto(
          page: 1,
          totalPages: 5,
          results: [MovieDto(id: 1, title: 'A')],
        ),
      );

      final result = await repo.category(MovieCategory.popular);

      expect(result.getOrThrow().items.single.title, 'A');
    });

    test('maps datasource exceptions to failures', () async {
      when(() => remote.search('x', 1)).thenThrow(const NetworkException());
      when(() => remote.genres()).thenThrow(const ServerException(500));

      expect(((await repo.search('x')) as Err).failure, isA<NetworkFailure>());
      expect(((await repo.genres()) as Err).failure, isA<ServerFailure>());
    });
  });
}

Map<String, dynamic> _decode(String source) =>
    jsonDecode(source) as Map<String, dynamic>;
