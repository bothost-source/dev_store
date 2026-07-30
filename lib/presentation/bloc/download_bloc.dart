import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/download_service.dart';
import '../../data/repositories/app_repository.dart';

// ============ EVENTS ============
abstract class DownloadEvent extends Equatable {
  const DownloadEvent();
  @override
  List<Object?> get props => [];
}

class StartDownload extends DownloadEvent {
  final String appId;
  final String url;
  final String fileName;
  final String appName;
  final String appIcon;
  const StartDownload({
    required this.appId,
    required this.url,
    required this.fileName,
    required this.appName,
    this.appIcon = '',
  });
  @override
  List<Object?> get props => [appId, url, fileName, appName, appIcon];
}

class CancelDownload extends DownloadEvent {
  final String appId;
  const CancelDownload({required this.appId});
  @override
  List<Object?> get props => [appId];
}

class InstallDownloadedApp extends DownloadEvent {
  final String appId;
  final String filePath;
  const InstallDownloadedApp({
    required this.appId,
    required this.filePath,
  });
  @override
  List<Object?> get props => [appId, filePath];
}

class ResetDownload extends DownloadEvent {
  final String appId;
  const ResetDownload({required this.appId});
  @override
  List<Object?> get props => [appId];
}

class _UpdateProgress extends DownloadEvent {
  final String appId;
  final double progress;
  final int receivedBytes;
  final int totalBytes;
  final double speedKbps;
  const _UpdateProgress({
    required this.appId,
    required this.progress,
    required this.receivedBytes,
    required this.totalBytes,
    this.speedKbps = 0,
  });
  @override
  List<Object?> get props => [appId, progress, receivedBytes, totalBytes, speedKbps];
}

class _DownloadComplete extends DownloadEvent {
  final String appId;
  final String filePath;
  const _DownloadComplete({
    required this.appId,
    required this.filePath,
  });
  @override
  List<Object?> get props => [appId, filePath];
}

class _DownloadError extends DownloadEvent {
  final String appId;
  final String message;
  const _DownloadError({
    required this.appId,
    required this.message,
  });
  @override
  List<Object?> get props => [appId, message];
}

class _DownloadCancelled extends DownloadEvent {
  final String appId;
  const _DownloadCancelled({required this.appId});
  @override
  List<Object?> get props => [appId];
}

// ============ STATES ============
abstract class DownloadState extends Equatable {
  const DownloadState();
  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {}

class DownloadsMapState extends DownloadState {
  final Map<String, AppDownloadState> downloads;
  const DownloadsMapState({this.downloads = const {}});

  AppDownloadState? getDownloadState(String appId) => downloads[appId];

  DownloadsMapState copyWith({
    Map<String, AppDownloadState>? downloads,
  }) {
    return DownloadsMapState(
      downloads: downloads ?? this.downloads,
    );
  }

  @override
  List<Object?> get props => [downloads];
}

class AppDownloadState extends Equatable {
  final String appId;
  final String appName;
  final String appIcon;
  final String status; // idle, downloading, completed, error, cancelled, installing, installed
  final double progress;
  final int receivedBytes;
  final int totalBytes;
  final double speedKbps; // Download speed in KB/s
  final String? filePath;
  final String? errorMessage;

  const AppDownloadState({
    required this.appId,
    required this.appName,
    this.appIcon = '',
    this.status = 'idle',
    this.progress = 0,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.speedKbps = 0,
    this.filePath,
    this.errorMessage,
  });

  AppDownloadState copyWith({
    String? appName,
    String? appIcon,
    String? status,
    double? progress,
    int? receivedBytes,
    int? totalBytes,
    double? speedKbps,
    String? filePath,
    String? errorMessage,
  }) {
    return AppDownloadState(
      appId: appId,
      appName: appName ?? this.appName,
      appIcon: appIcon ?? this.appIcon,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      speedKbps: speedKbps ?? this.speedKbps,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isIdle => status == 'idle';
  bool get isDownloading => status == 'downloading';
  bool get isCompleted => status == 'completed';
  bool get isError => status == 'error';
  bool get isCancelled => status == 'cancelled';
  bool get isInstalling => status == 'installing';
  bool get isInstalled => status == 'installed';

  @override
  List<Object?> get props => [appId, status, progress, receivedBytes, totalBytes, filePath, errorMessage];
}

// ============ BLoC ============
class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadService _downloadService;
  final AppRepository _appRepository;

  DownloadBloc(this._downloadService, this._appRepository) : super(DownloadInitial()) {
    on<StartDownload>(_onStartDownload);
    on<CancelDownload>(_onCancelDownload);
    on<InstallDownloadedApp>(_onInstallApp);
    on<ResetDownload>(_onResetDownload);
    on<_UpdateProgress>(_onUpdateProgress);
    on<_DownloadComplete>(_onDownloadComplete);
    on<_DownloadError>(_onDownloadError);
    on<_DownloadCancelled>(_onDownloadCancelled);
  }

  Map<String, AppDownloadState> _getCurrentMap() {
    if (state is DownloadsMapState) {
      return Map<String, AppDownloadState>.from((state as DownloadsMapState).downloads);
    }
    return {};
  }

  Future<void> _onStartDownload(StartDownload event, Emitter<DownloadState> emit) async {
    final downloads = _getCurrentMap();
    downloads[event.appId] = AppDownloadState(
      appId: event.appId,
      appName: event.appName,
      appIcon: event.appIcon,
      status: 'downloading',
      progress: 0,
      receivedBytes: 0,
      totalBytes: 0,
      speedKbps: 0,
    );
    emit(DownloadsMapState(downloads: downloads));

    int lastReceived = 0;
    DateTime lastTime = DateTime.now();

    try {
      final filePath = await _downloadService.downloadApk(
        url: event.url,
        fileName: event.fileName,
        appId: event.appId,
        onProgress: (received, total) {
          final now = DateTime.now();
          final elapsed = now.difference(lastTime).inMilliseconds;
          double speed = 0;
          if (elapsed > 0) {
            final bytesDelta = received - lastReceived;
            speed = (bytesDelta / 1024) / (elapsed / 1000); // KB/s
          }
          lastReceived = received;
          lastTime = now;

          // Called directly from Dio's onReceiveProgress - real progress
          add(_UpdateProgress(
            appId: event.appId,
            progress: total > 0 ? received / total : 0,
            receivedBytes: received,
            totalBytes: total,
            speedKbps: speed,
          ));
        },
      );

      await _appRepository.incrementDownloadCount(event.appId);
      add(_DownloadComplete(appId: event.appId, filePath: filePath));
    } catch (e) {
      if (e.toString().contains('cancelled') || e.toString().contains('Cancel')) {
        add(_DownloadCancelled(appId: event.appId));
      } else {
        add(_DownloadError(appId: event.appId, message: e.toString()));
      }
    }
  }

  void _onUpdateProgress(_UpdateProgress event, Emitter<DownloadState> emit) {
    final downloads = _getCurrentMap();
    final current = downloads[event.appId];
    if (current != null && current.isDownloading) {
      downloads[event.appId] = current.copyWith(
        status: 'downloading',
        progress: event.progress,
        receivedBytes: event.receivedBytes,
        totalBytes: event.totalBytes,
        speedKbps: event.speedKbps,
      );
      emit(DownloadsMapState(downloads: downloads));
    }
  }

  void _onDownloadComplete(_DownloadComplete event, Emitter<DownloadState> emit) {
    final downloads = _getCurrentMap();
    final current = downloads[event.appId];
    if (current != null) {
      downloads[event.appId] = current.copyWith(
        status: 'completed',
        progress: 1.0,
        filePath: event.filePath,
      );
      emit(DownloadsMapState(downloads: downloads));
    }
  }

  void _onDownloadError(_DownloadError event, Emitter<DownloadState> emit) {
    final downloads = _getCurrentMap();
    final current = downloads[event.appId];
    if (current != null) {
      downloads[event.appId] = current.copyWith(
        status: 'error',
        errorMessage: event.message,
      );
      emit(DownloadsMapState(downloads: downloads));
    }
  }

  void _onDownloadCancelled(_DownloadCancelled event, Emitter<DownloadState> emit) {
    final downloads = _getCurrentMap();
    final current = downloads[event.appId];
    if (current != null) {
      downloads[event.appId] = current.copyWith(
        status: 'cancelled',
        progress: 0,
      );
      emit(DownloadsMapState(downloads: downloads));
    }
  }

  Future<void> _onCancelDownload(CancelDownload event, Emitter<DownloadState> emit) async {
    _downloadService.cancelDownload(event.appId);
  }

  Future<void> _onInstallApp(InstallDownloadedApp event, Emitter<DownloadState> emit) async {
    final downloads = _getCurrentMap();
    final current = downloads[event.appId];
    if (current != null) {
      downloads[event.appId] = current.copyWith(status: 'installing');
      emit(DownloadsMapState(downloads: downloads));
    }

    try {
      await _downloadService.installApk(event.filePath);
      final downloads = _getCurrentMap();
      final current = downloads[event.appId];
      if (current != null) {
        downloads[event.appId] = current.copyWith(status: 'installed');
        emit(DownloadsMapState(downloads: downloads));
      }
    } catch (e) {
      final downloads = _getCurrentMap();
      final current = downloads[event.appId];
      if (current != null) {
        downloads[event.appId] = current.copyWith(
          status: 'error',
          errorMessage: e.toString(),
        );
        emit(DownloadsMapState(downloads: downloads));
      }
    }
  }

  Future<void> _onResetDownload(ResetDownload event, Emitter<DownloadState> emit) async {
    final downloads = _getCurrentMap();
    downloads.remove(event.appId);
    emit(DownloadsMapState(downloads: downloads));
  }
}
