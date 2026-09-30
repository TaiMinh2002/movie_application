import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/movie.dart';

part 'movie_dto.freezed.dart';
part 'movie_dto.g.dart';

@freezed
abstract class MovieDto with _$MovieDto {
  const factory MovieDto({
    required int id,
    required String title,
    @Default('') String overview,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'vote_average') @Default(0) double voteAverage,
    @JsonKey(name: 'release_date') String? releaseDate,
  }) = _MovieDto;

  const MovieDto._();

  factory MovieDto.fromJson(Map<String, dynamic> json) =>
      _$MovieDtoFromJson(json);

  Movie toEntity() => Movie(
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    voteAverage: voteAverage,
    // TMDB sends "" for unknown dates; tryParse turns that into null.
    releaseDate: DateTime.tryParse(releaseDate ?? ''),
  );
}

@freezed
abstract class MoviePageDto with _$MoviePageDto {
  const factory MoviePageDto({
    required int page,
    @JsonKey(name: 'total_pages') required int totalPages,
    @Default([]) List<MovieDto> results,
  }) = _MoviePageDto;

  const MoviePageDto._();

  factory MoviePageDto.fromJson(Map<String, dynamic> json) =>
      _$MoviePageDtoFromJson(json);

  MoviePage toEntity() => MoviePage(
    items: [for (final m in results) m.toEntity()],
    page: page,
    totalPages: totalPages,
  );
}

@freezed
abstract class GenreDto with _$GenreDto {
  const factory GenreDto({required int id, required String name}) = _GenreDto;

  const GenreDto._();

  factory GenreDto.fromJson(Map<String, dynamic> json) =>
      _$GenreDtoFromJson(json);

  Genre toEntity() => Genre(id: id, name: name);
}

@freezed
abstract class CastDto with _$CastDto {
  const factory CastDto({
    required int id,
    required String name,
    @Default('') String character,
    @JsonKey(name: 'profile_path') String? profilePath,
  }) = _CastDto;

  factory CastDto.fromJson(Map<String, dynamic> json) =>
      _$CastDtoFromJson(json);
}

@freezed
abstract class VideoDto with _$VideoDto {
  const factory VideoDto({
    required String key,
    @Default('') String site,
    @Default('') String type,
  }) = _VideoDto;

  factory VideoDto.fromJson(Map<String, dynamic> json) =>
      _$VideoDtoFromJson(json);
}

@freezed
abstract class ProviderDto with _$ProviderDto {
  const factory ProviderDto({
    @JsonKey(name: 'provider_name') required String name,
    @JsonKey(name: 'logo_path') String? logoPath,
  }) = _ProviderDto;

  factory ProviderDto.fromJson(Map<String, dynamic> json) =>
      _$ProviderDtoFromJson(json);
}

/// `/movie/{id}` with `append_to_response=credits,videos,similar,watch/providers`.
@freezed
abstract class MovieDetailDto with _$MovieDetailDto {
  const factory MovieDetailDto({
    required MovieDto movie,
    int? runtime,
    @Default([]) List<GenreDto> genres,
    @Default([]) List<CastDto> cast,
    @Default([]) List<VideoDto> videos,
    @Default([]) List<MovieDto> similar,
    @Default([]) List<ProviderDto> providers,
  }) = _MovieDetailDto;

  const MovieDetailDto._();

  /// The appended responses are nested objects, so flatten them here instead
  /// of modelling each wrapper as a class.
  factory MovieDetailDto.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(Object? raw, T Function(Map<String, dynamic>) parse) => [
      for (final e in (raw as List? ?? const []))
        parse(e as Map<String, dynamic>),
    ];
    final region =
        ((json['watch/providers'] as Map?)?['results']
                as Map?)?[ApiConstants.watchRegion]
            as Map?;
    return MovieDetailDto(
      movie: MovieDto.fromJson(json),
      runtime: json['runtime'] as int?,
      genres: list(json['genres'], GenreDto.fromJson),
      cast: list((json['credits'] as Map?)?['cast'], CastDto.fromJson),
      videos: list((json['videos'] as Map?)?['results'], VideoDto.fromJson),
      similar: list((json['similar'] as Map?)?['results'], MovieDto.fromJson),
      providers: list(region?['flatrate'], ProviderDto.fromJson),
    );
  }

  MovieDetail toEntity() => MovieDetail(
    movie: movie.toEntity(),
    runtime: runtime == 0 ? null : runtime,
    genres: [for (final g in genres) g.toEntity()],
    cast: [
      for (final c in cast)
        CastMember(
          id: c.id,
          name: c.name,
          character: c.character,
          profilePath: c.profilePath,
        ),
    ],
    trailerKey: _trailerKey(),
    similar: [for (final m in similar) m.toEntity()],
    providers: [
      for (final p in providers)
        WatchProvider(name: p.name, logoPath: p.logoPath),
    ],
  );

  String? _trailerKey() {
    final youtube = videos.where((v) => v.site == 'YouTube');
    final trailers = youtube.where((v) => v.type == 'Trailer');
    return (trailers.isNotEmpty ? trailers : youtube).firstOrNull?.key;
  }
}
