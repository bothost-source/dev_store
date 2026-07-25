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
  const StartDownload({
    required this.appId,
    required this.url,
    required this.fileName,
  });
  @override
  List<Object?> get props => [appId, url, fileName];
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

// ============ STATES ============
abstract class DownloadState extends Equatable {
  const DownloadState();
  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {}

class DownloadInProgress extends DownloadState {
  final String appId;
  final double progress; // 0.0 to 1.0
  final int receivedBytes;
  final int totalBytes;
  const DownloadInProgress({
    required this.appId,
    required this.progress,
    required this.receivedBytes,
    required this.totalBytes,
  });
  @override
  List<Object?> get props => [appId, progress, receivedBytes, totalBytes];
}

class DownloadCompleted extends DownloadState {
  final String appId;
  final String filePath;
  const DownloadCompleted({
    required this.appId,
    required this.filePath,
  });
  @override
  List<Object?> get props => [appId, filePath];
}

class DownloadError extends DownloadState {
  final String appId;
  final String message;
  const DownloadError({
    required this.appId,
    required this.message,
  });
  @override
  List<Object?> get props => [appId, message];
}

class DownloadCancelled extends DownloadState {
  final String appId;
  const DownloadCancelled({required this.appId});
  @override
  List<Object?> get props => [appId];
}

class Installing extends DownloadState {
  final String appId;
  const Installing({required this.appId});
  @override
  List<Object?> get props => [appId];
}

class InstallSuccess extends DownloadState {
  final String appId;
  const InstallSuccess({required this.appId});
  @override
  List<Object?> get props => [appId];
}

class InstallError extends DownloadState {
  final String appId;
  final String message;
  const InstallError({
    required this.appId,
    required this.message,
  });
  @override
  List<Object?> get props => [appId, message];
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
  }

  Future<void> _onStartDownload(StartDownload event, Emitter<DownloadState> emit) async {
    emit(DownloadInProgress(
      appId: event.appId,
      progress: 0,
      receivedBytes: 0,
      totalBytes: 0,
    ));

    try {
      await for (final downloadProgress in _downloadService.downloadWithProgress(
        url: event.url,
        fileName: event.fileName,
        appId: event.appId,
      )) {
        emit(DownloadInProgress(
          appId: event.appId,
          progress: downloadProgress.progress,
          receivedBytes: downloadProgress.receivedBytes,
          totalBytes: downloadProgress.totalBytes,
        ));
      }

      final filePath = await _downloadService.getDownloadedFilePath(event.fileName);

      if (filePath != null && filePath.isNotEmpty) {
        await _appRepository.incrementDownloadCount(event.appId);
        emit(DownloadCompleted(appId: event.appId, filePath: filePath));
      } else {
        emit(DownloadError(
          appId: event.appId,
          message: 'Download failed: file not found',
        ));
      }
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        emit(DownloadCancelled(appId: event.appId));
      } else {
        emit(DownloadError(appId: event.appId, message: e.toString()));
      }
    }
  }

  Future<void> _onCancelDownload(CancelDownload event, Emitter<DownloadState> emit) async {
    _downloadService.cancelDownload(event.appId);
    emit(DownloadCancelled(appId: event.appId));
  }

  Future<void> _onInstallApp(InstallDownloadedApp event, Emitter<DownloadState> emit) async {
    emit(Installing(appId: event.appId));
    try {
      await _downloadService.installApk(event.filePath);
      emit(InstallSuccess(appId: event.appId));
    } catch (e) {
      emit(InstallError(appId: event.appId, message: e.toString()));
    }
  }

  Future<void> _onResetDownload(ResetDownload event, Emitter<DownloadState> emit) async {
    emit(DownloadInitial());
  }
}
