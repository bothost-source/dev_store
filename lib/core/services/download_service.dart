import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_filex/open_filex.dart';

class DownloadService {
  final Dio _dio = Dio();

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

  Future<String> downloadApk({
    required String url,
    required String fileName,
    required Function(int received, int total) onProgress,
  }) async {
    final downloadDir = await _getDownloadDirectory();
    final filePath = path.join(downloadDir.path, fileName);
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          onProgress(received, total);
        }
      },
    );

    return filePath;
  }

  Future<void> installApk(String filePath) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('APK installation is only supported on Android');
    }

    final result = await OpenFilex.open(filePath);

    if (result.type != ResultType.done) {
      throw Exception('Failed to open APK installer: ${result.message}');
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

  Stream<double> downloadWithProgress({
    required String url,
    required String fileName,
  }) async* {
    final downloadDir = await _getDownloadDirectory();
    final filePath = path.join(downloadDir.path, fileName);

    final progressController = StreamController<double>.broadcast();
    late final Future<Response> downloadFuture;

    downloadFuture = _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1 && !progressController.isClosed) {
          progressController.add(received / total);
        }
      },
    );

    await for (final progress in progressController.stream) {
      yield progress;
    }

    final response = await downloadFuture;

    if (response.statusCode == 200) {
      if (!progressController.isClosed) {
        progressController.add(1.0);
      }
      yield 1.0;
    } else {
      throw Exception('Download failed: ${response.statusCode}');
    }

    await progressController.close();
  }
}
