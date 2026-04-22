/// Pre-signed S3 upload service.
///
/// Flow:
///   1. [requestPresignUrl] → backend returns `{ uploadUrl, tempKey }`
///   2. [uploadToPresignedUrl] → client PUTs file bytes directly to S3
///   3. Pass `tempKey` in the profile/KYC update request body
///   4. Backend calls `moveFromTempIfNeeded(tempKey)` on its side
///
/// The temp file is auto-deleted after 7 days by a weekly backend job if
/// the upload is never finalized (e.g. user cancelled the form).
library;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';

class PresignResult {
  const PresignResult({
    required this.uploadUrl,
    required this.tempKey,
    required this.expiresIn,
  });

  final String uploadUrl;
  final String tempKey;
  final int expiresIn;

  factory PresignResult.fromJson(Map<String, dynamic> json) => PresignResult(
        uploadUrl: json['uploadUrl'] as String,
        tempKey: json['tempKey'] as String,
        expiresIn: (json['expiresIn'] as num).toInt(),
      );
}

class UploadService {
  UploadService(this._client);
  final ApiClient _client;

  /// Request a pre-signed PUT URL from the backend.
  ///
  /// [category] — `profiles` or `kyc`
  /// [contentType] — MIME type of the file being uploaded (e.g. `image/jpeg`)
  Future<PresignResult> requestPresignUrl({
    required String category,
    required String contentType,
  }) async {
    final response = await _client.get(
      Endpoints.uploads.presign,
      queryParameters: {
        'category': category,
        'contentType': contentType,
      },
    );
    // Backend envelope: { ok, data: { uploadUrl, tempKey, expiresIn } }
    final inner = response.data['data'] as Map<String, dynamic>;
    return PresignResult.fromJson(inner);
  }

  /// Upload a file directly to S3 using a pre-signed PUT URL.
  ///
  /// Uses a separate Dio instance (no auth headers — the URL is already signed).
  /// Returns the [tempKey] on success.
  Future<String> uploadToPresignedUrl({
    required String uploadUrl,
    required String tempKey,
    required File file,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    await Dio().put<void>(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Content-Length': bytes.length,
        },
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 2),
      ),
      onSendProgress: onProgress,
    );
    return tempKey;
  }

  /// Convenience: request presign URL then immediately upload [file].
  /// Returns the [tempKey] to be passed with the form submission.
  Future<String> presignAndUpload({
    required File file,
    required String category,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  }) async {
    final presign = await requestPresignUrl(
      category: category,
      contentType: contentType,
    );
    return uploadToPresignedUrl(
      uploadUrl: presign.uploadUrl,
      tempKey: presign.tempKey,
      file: file,
      contentType: contentType,
      onProgress: onProgress,
    );
  }
}

final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService(ref.read(apiClientProvider));
});
