import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

class DownloadService {
  final Dio _dio = Dio();

  DownloadService() {
    _dio.options.connectTimeout = const Duration(minutes: 5);
    _dio.options.receiveTimeout = const Duration(minutes: 5);
  }

  Future<String> downloadApk({
    required String url,
    required String fileName,
    required Function(int received, int total) onProgress,
  }) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission denied');
    }

    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/devstore_downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

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
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/devstore_downloads/$fileName');
    return await file.exists();
  }

  Future<String?> getDownloadedFilePath(String fileName) async {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/devstore_downloads/$fileName');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<void> deleteDownloadedFile(String fileName) async {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/devstore_downloads/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Stream<double> downloadWithProgress({
    required String url,
    required String fileName,
  }) async* {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final filePath = path.join(dir.path, 'devstore_downloads', fileName);

    final response = await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {}
      },
    );

    if (response.statusCode == 200) {
      yield 1.0;
    } else {
      throw Exception('Download failed: ${response.statusCode}');
    }
  }
}
