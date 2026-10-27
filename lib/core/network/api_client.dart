import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final client = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.requestTimeout,
      receiveTimeout: AppConstants.requestTimeout,
      sendTimeout: AppConstants.requestTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  client.interceptors.add(
    LogInterceptor(requestBody: false, responseBody: false),
  );
  ref.onDispose(client.close);
  return client;
});
