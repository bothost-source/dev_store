import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/download_service.dart';
import '../../data/repositories/app_repository.dart';

// Events
abstract class DownloadEvent extends Equatable {
  const DownloadEvent();
  @override
  List<Object?> get props => [];
}

class StartDownload extends DownloadEvent {
  final String appId;
  final String url;
  final String fileName;
  const StartDownload({required this.appId, required this.url, required this.fileName});
  @override
  List<Object?> get props => [appId, url, fileName];
}

class CancelDownload extends DownloadEvent {
  final String appId;
  const CancelDownload(this.appId);
  @override
  List<Object?> get props => [appId];
}

class InstallDownloadedApp extends DownloadEvent {
  final String appId;
  final String filePath;
  const InstallDownloadedApp({required this.appId, required this.filePath});
  @override
  List<Object?> get props => [appId, filePath];
}

class ResetDownload extends DownloadEvent {
  final String appId;
  const ResetDownload(this.appId);
  @override
  List<Object?> get props => [appId];
}

// States
abstract class DownloadState extends Equatable {
  const DownloadState();
  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {}

class DownloadInProgress extends DownloadState {
  final String appId;
  final double progress;
  final int received;
  final int total;
  const DownloadInProgress({
    required this.appId,
    required this.progress,
    required this.received,
    required this.total,
  });
  @override
  List<Object?> get props => [appId, progress, received, total];
}

class DownloadCompleted extends DownloadState {
  final String appId;
  final String filePath;
  const DownloadCompleted({required this.appId, required this.filePath});
  @override
  List<Object?> get props => [appId, filePath];
}

class DownloadError extends DownloadState {
  final String appId;
  final String message;
  const DownloadError({required this.appId, required this.message});
  @override
  List<Object?> get props => [appId, message];
}

class Installing extends DownloadState {
  final String appId;
  const Installing(this.appId);
  @override
  List<Object?> get props => [appId];
}

class InstallSuccess extends DownloadState {
  final String appId;
  const InstallSuccess(this.appId);
  @override
  List<Object?> get props => [appId];
}

class InstallError extends DownloadState {
  final String appId;
  final String message;
  const InstallError({required this.appId, required this.message});
  @override
  List<Object?> get props => [appId, message];
}

// BLoC
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
    emit(DownloadInProgress(appId: event.appId, progress: 0, received: 0, total: 100));
    
    try {
      await for (final progress in _downloadService.downloadWithProgress(
        url: event.url,
        fileName: event.fileName,
      )) {
        emit(DownloadInProgress(
          appId: event.appId,
          progress: progress,
          received: (progress * 100).toInt(),
          total: 100,
        ));
      }

      final filePath = await _downloadService.getDownloadedFilePath(event.fileName);
      if (filePath != null) {
        await _appRepository.incrementDownloadCount(event.appId);
        emit(DownloadCompleted(appId: event.appId, filePath: filePath));
      } else {
        emit(DownloadError(appId: event.appId, message: 'Download failed: file not found'));
      }
    } catch (e) {
      emit(DownloadError(appId: event.appId, message: e.toString()));
    }
  }

  Future<void> _onCancelDownload(CancelDownload event, Emitter<DownloadState> emit) async {
    // Cancel the current download
    emit(DownloadInitial());
  }

  Future<void> _onInstallApp(InstallDownloadedApp event, Emitter<DownloadState> emit) async {
    emit(Installing(event.appId));
    try {
      await _downloadService.installApk(event.filePath);
      emit(InstallSuccess(event.appId));
    } catch (e) {
      emit(InstallError(appId: event.appId, message: e.toString()));
    }
  }

  Future<void> _onResetDownload(ResetDownload event, Emitter<DownloadState> emit) async {
    emit(DownloadInitial());
  }
}
