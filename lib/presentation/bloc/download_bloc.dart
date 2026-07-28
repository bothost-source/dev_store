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

class UpdateDownloadProgress extends DownloadEvent {
  final String appId;
  final double progress;
  final int receivedBytes;
  final int totalBytes;
  const UpdateDownloadProgress({
    required this.appId,
    required this.progress,
    required this.receivedBytes,
    required this.totalBytes,
  });
  @override
  List<Object?> get props => [appId, progress, receivedBytes, totalBytes];
}

class DownloadCompleteEvent extends DownloadEvent {
  final String appId;
  final String filePath;
  const DownloadCompleteEvent({
    required this.appId,
    required this.filePath,
  });
  @override
  List<Object?> get props => [appId, filePath];
}

class DownloadErrorEvent extends DownloadEvent {
  final String appId;
  final String message;
  const DownloadErrorEvent({
    required this.appId,
    required this.message,
  });
  @override
  List<Object?> get props => [appId, message];
}

class DownloadCancelledEvent extends DownloadEvent {
  final String appId;
  const DownloadCancelledEvent({required this.appId});
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
    on<UpdateDownloadProgress>(_onUpdateProgress);
    on<DownloadCompleteEvent>(_onDownloadComplete);
    on<DownloadErrorEvent>(_onDownloadError);
    on<DownloadCancelledEvent>(_onDownloadCancelled);
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
    );
    emit(DownloadsMapState(downloads: downloads));

    try {
      await for (final downloadProgress in _downloadService.downloadWithProgress(
        url: event.url,
        fileName: event.fileName,
        appId: event.appId,
      )) {
        add(UpdateDownloadProgress(
          appId: event.appId,
          progress: downloadProgress.progress,
          receivedBytes: downloadProgress.receivedBytes,
          totalBytes: downloadProgress.totalBytes,
        ));
      }

      final filePath = await _downloadService.getDownloadedFilePath(event.fileName);

      if (filePath != null && filePath.isNotEmpty) {
        await _appRepository.incrementDownloadCount(event.appId);
        add(DownloadCompleteEvent(appId: event.appId, filePath: filePath));
      } else {
        add(DownloadErrorEvent(
          appId: event.appId,
          message: 'Download failed: file not found',
        ));
      }
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        add(DownloadCancelledEvent(appId: event.appId));
      } else {
        add(DownloadErrorEvent(appId: event.appId, message: e.toString()));
      }
    }
  }

  void _onUpdateProgress(UpdateDownloadProgress event, Emitter<DownloadState> emit) {
    final downloads = _getCurrentMap();
    final current = downloads[event.appId];
    if (current != null) {
      downloads[event.appId] = current.copyWith(
        status: 'downloading',
        progress: event.progress,
        receivedBytes: event.receivedBytes,
        totalBytes: event.totalBytes,
      );
      emit(DownloadsMapState(downloads: downloads));
    }
  }

  void _onDownloadComplete(DownloadCompleteEvent event, Emitter<DownloadState> emit) {
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

  void _onDownloadError(DownloadErrorEvent event, Emitter<DownloadState> emit) {
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

  void _onDownloadCancelled(DownloadCancelledEvent event, Emitter<DownloadState> emit) {
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
    final downloads = _getCurrentMap();
    final current = downloads[event.appId];
    if (current != null) {
      downloads[event.appId] = current.copyWith(status: 'cancelled');
      emit(DownloadsMapState(downloads: downloads));
    }
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
