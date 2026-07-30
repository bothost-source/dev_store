import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_filex/open_filex.dart';

class DownloadService {
  final Dio _dio = Dio();
  final Map<String, CancelToken> _activeTokens = {};

  DownloadService() {
    _dio.options.connectTimeout = const Duration(minutes: 5);
    _dio.options.receiveTimeout = const Duration(minutes: 5);
  }

  Future<Directory> _getDownloadDirectory() async {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/devstore_downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  /// Get file size from URL via HEAD request
  Future<int> _getFileSize(String url) async {
    try {
      final response = await _dio.head(url);
      final contentLength = response.headers.value('content-length');
      if (contentLength != null) {
        return int.parse(contentLength);
      }
    } catch (e) {
      // HEAD request failed, will use unknown size
    }
    return 0;
  }

  /// Downloads an APK with progress callbacks.
  /// [onProgress] is called with (receivedBytes, totalBytes) periodically.
  /// If totalBytes is 0, the server didn't report size - progress will be indeterminate.
  Future<String> downloadApk({
    required String url,
    required String fileName,
    required void Function(int received, int total) onProgress,
    String? appId,
  }) async {
    final downloadDir = await _getDownloadDirectory();
    final filePath = path.join(downloadDir.path, fileName);
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    // Try to get file size first
    int totalBytes = await _getFileSize(url);
    int receivedBytes = 0;

    final cancelToken = CancelToken();
    if (appId != null) {
      _activeTokens[appId] = cancelToken;
    }

    try {
      final response = await _dio.get(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
        onReceiveProgress: (received, total) {
          // Dio's total might be -1 if Content-Length not available
          // Use our pre-fetched total if available
          if (total != -1 && total > 0) {
            totalBytes = total;
          }
          receivedBytes = received;
          onProgress(receivedBytes, totalBytes);
        },
      );

      // Write the bytes to file
      await file.writeAsBytes(response.data as List<int>);

      // Final progress update
      receivedBytes = await file.length();
      onProgress(receivedBytes, totalBytes > 0 ? totalBytes : receivedBytes);

      return filePath;
    } finally {
      if (appId != null) {
        _activeTokens.remove(appId);
      }
    }
  }

  void cancelDownload(String appId) {
    final token = _activeTokens[appId];
    if (token != null && !token.isCancelled) {
      token.cancel('User cancelled download');
      _activeTokens.remove(appId);
    }
  }

  Future<void> installApk(String filePath) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('APK installation is only supported on Android');
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('APK file not found at: $filePath');
    }

    final result = await OpenFilex.open(
      filePath,
      type: 'application/vnd.android.package-archive',
    );

    if (result.type != ResultType.done && result.type != ResultType.noAppToOpen) {
      throw Exception('Failed to open APK: ${result.message} (type: ${result.type})');
    }
  }

  Future<void> openFile(String filePath) async {
    await OpenFilex.open(filePath);
  }

  Future<bool> isDownloaded(String fileName) async {
    final downloadDir = await _getDownloadDirectory();
    final file = File(path.join(downloadDir.path, fileName));
    return await file.exists();
  }

  Future<String?> getDownloadedFilePath(String fileName) async {
    final downloadDir = await _getDownloadDirectory();
    final file = File(path.join(downloadDir.path, fileName));
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<void> deleteDownloadedFile(String fileName) async {
    final downloadDir = await _getDownloadDirectory();
    final file = File(path.join(downloadDir.path, fileName));
    if (await file.exists()) {
      await file.delete();
    }
  }
}
