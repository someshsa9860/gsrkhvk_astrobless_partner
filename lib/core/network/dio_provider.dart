import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

/// Riverpod provider that exposes the raw [Dio] instance from [ApiClient].
///
/// Prefer [apiClientProvider] in repositories; use this only when direct
/// [Dio] access is required (e.g. streaming responses with custom [Options]).
final dioProvider = Provider<Dio>((ref) => ref.read(apiClientProvider).rawDio);
