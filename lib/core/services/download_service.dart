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

  /// Downloads with progress callback. Returns filePath on success.
  Future<String> downloadApk({
    required String url,
    required String fileName,
    required Function(int received, int total) onProgress,
    String? appId,
  }) async {
    final downloadDir = await _getDownloadDirectory();
    final filePath = path.join(downloadDir.path, fileName);
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    final cancelToken = CancelToken();
    if (appId != null) {
      _activeTokens[appId] = cancelToken;
    }

    try {
      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received, total);
          }
        },
      );

      return filePath;
    } finally {
      if (appId != null) {
        _activeTokens.remove(appId);
      }
    }
  }

  /// Stream-based download with proper cancel support
  /// Yields DownloadProgress objects with actual bytes
  Stream<DownloadProgress> downloadWithProgress({
    required String url,
    required String fileName,
    String? appId,
  }) async* {
    final downloadDir = await _getDownloadDirectory();
    final filePath = path.join(downloadDir.path, fileName);
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    final cancelToken = CancelToken();
    if (appId != null) {
      _activeTokens[appId] = cancelToken;
    }

    try {
      int totalBytes = 0;
      int receivedBytes = 0;

      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            totalBytes = total;
            receivedBytes = received;
          }
        },
      );

      // Yield final progress
      yield DownloadProgress(
        receivedBytes: receivedBytes,
        totalBytes: totalBytes,
        progress: totalBytes > 0 ? receivedBytes / totalBytes : 1.0,
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        throw Exception('Download cancelled by user');
      }
      rethrow;
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

class DownloadProgress {
  final int receivedBytes;
  final int totalBytes;
  final double progress;

  const DownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
    required this.progress,
  });
}
