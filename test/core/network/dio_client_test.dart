import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_application/core/error/errors.dart';
import 'package:movie_application/core/network/dio_client.dart';

DioException _dio(DioExceptionType type, {int? status}) => DioException(
  requestOptions: RequestOptions(),
  type: type,
  response: status == null
      ? null
      : Response(requestOptions: RequestOptions(), statusCode: status),
);

void main() {
  test('connection problems become NetworkException', () {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      expect(_dio(type).toAppException(), isA<NetworkException>());
    }
  });

  test('bad responses become ServerException with the status code', () {
    final e = _dio(DioExceptionType.badResponse, status: 401).toAppException();
    expect(e, isA<ServerException>().having((s) => s.statusCode, 'code', 401));
  });
}
