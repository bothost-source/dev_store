import 'dart:io';
import 'package:minio/minio.dart';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';

class StorjService {
  late Minio _minio;
  int _currentBucketIndex = 0;

  StorjService() {
    _initMinio();
  }

  void _initMinio() {
    _minio = Minio(
      endPoint: 'gateway.storjshare.io',
      accessKey: AppConstants.storjAccessKey,
      secretKey: 'jy647zcnkgxg2p5csckibatsb6zcbspmqjcbv2cnpg76ocsauzjdc',
      useSSL: true,
    );
  }

  String get _currentBucket => AppConstants.storjBuckets[_currentBucketIndex];

  String get _nextBucket {
    _currentBucketIndex = (_currentBucketIndex + 1) % AppConstants.storjBuckets.length;
    return AppConstants.storjBuckets[_currentBucketIndex];
  }

  Future<String> uploadFile({
    required File file,
    required String folder,
    required String fileName,
    String? specificBucket,
  }) async {
    try {
      final bucket = specificBucket ?? _currentBucket;
      final objectPath = '$folder/$fileName';

      await _minio.fPutObject(
        bucket,
        objectPath,
        file.path,
      );

      return '$bucket/$objectPath';
    } catch (e) {
      if (specificBucket == null) {
        final fallbackBucket = _nextBucket;
        final objectPath = '$folder/$fileName';

        await _minio.fPutObject(
          fallbackBucket,
          objectPath,
          file.path,
        );

        return '$fallbackBucket/$objectPath';
      }
      rethrow;
    }
  }

  String getPublicUrl(String bucket, String objectPath) {
    return 'https://link.storjshare.io/s/${AppConstants.storjAccessKey}/$bucket/$objectPath';
  }

  Future<void> deleteFile(String bucket, String objectPath) async {
    await _minio.removeObject(bucket, objectPath);
  }

  Future<Map<String, dynamic>> getFileInfo(String bucket, String objectPath) async {
    final stat = await _minio.statObject(bucket, objectPath);
    return {
      'size': stat.size,
      'lastModified': stat.lastModified,
      'etag': stat.etag,
    };
  }

  Future<int> getBucketUsage(String bucket) async {
    int totalSize = 0;
    await for (final object in _minio.listObjects(bucket)) {
      totalSize += object.size ?? 0;
    }
    return totalSize;
  }

  Future<String> getAvailableBucket() async {
    for (final bucket in AppConstants.storjBuckets) {
      final usage = await getBucketUsage(bucket);
      if (usage < 25 * 1024 * 1024 * 1024) {
        return bucket;
      }
    }
    throw Exception('All buckets are full');
  }
}
