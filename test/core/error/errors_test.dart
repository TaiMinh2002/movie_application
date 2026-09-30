import 'package:flutter_test/flutter_test.dart';
import 'package:movie_application/core/error/errors.dart';

void main() {
  test('guard maps exceptions to failures', () async {
    expect(await guard(() async => 1), isA<Ok<int>>());
    expect(
      ((await guard<int>(() => throw const NetworkException())) as Err).failure,
      isA<NetworkFailure>(),
    );
    expect(
      ((await guard<int>(
        () => throw const ServerException(500),
      )) as Err).failure,
      isA<ServerFailure>(),
    );
    expect(
      ((await guard<int>(() => throw StateError('x'))) as Err).failure,
      isA<UnknownFailure>(),
    );
  });

  test('getOrThrow returns data or throws the failure', () {
    expect(const Ok(1).getOrThrow(), 1);
    expect(
      () => const Err<int>(ServerFailure()).getOrThrow(),
      throwsA(isA<ServerFailure>()),
    );
  });
}
