import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://your-api-url.com/api', // Ganti dengan base URL API kamu
    headers: {
      'Accept': 'application/json',
      // Tambahkan token kalau pakai auth
    },
  ));
  return dio;
});
