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
}

class CancelDownload extends DownloadEvent {}
class InstallDownloadedApp extends DownloadEvent {
  final String filePath;
  const InstallDownloadedApp(this.filePath);
}

// States
abstract class DownloadState extends Equatable {
  const DownloadState();
  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {}
class DownloadInProgress extends DownloadState {
  final double progress;
  final int received;
  final int total;
  const DownloadInProgress({required this.progress, required this.received, required this.total});
  @override
  List<Object?> get props => [progress, received, total];
}

class DownloadCompleted extends DownloadState {
  final String filePath;
  const DownloadCompleted(this.filePath);
  @override
  List<Object?> get props => [filePath];
}

class DownloadError extends DownloadState {
  final String message;
  const DownloadError(this.message);
  @override
  List<Object?> get props => [message];
}

class Installing extends DownloadState {}
class InstallSuccess extends DownloadState {}
class InstallError extends DownloadState {
  final String message;
  const InstallError(this.message);
}

// BLoC
class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadService _downloadService;
  final AppRepository _appRepository;

  DownloadBloc(this._downloadService, this._appRepository) : super(DownloadInitial()) {
    on<StartDownload>(_onStartDownload);
    on<InstallDownloadedApp>(_onInstallApp);
  }

  Future<void> _onStartDownload(StartDownload event, Emitter<DownloadState> emit) async {
    emit(const DownloadInProgress(progress: 0, received: 0, total: 0));
    try {
      final filePath = await _downloadService.downloadApk(
        url: event.url,
        fileName: event.fileName,
        onProgress: (received, total) {
          final progress = total > 0 ? (received / total).toDouble() : 0.0;  // ✅ FIXED: cast to double
          emit(DownloadInProgress(
            progress: progress,
            received: received,
            total: total,
          ));
        },
      );

      // Increment download count
      await _appRepository.incrementDownloadCount(event.appId);

      emit(DownloadCompleted(filePath));
    } catch (e) {
      emit(DownloadError(e.toString()));
    }
  }

  Future<void> _onInstallApp(InstallDownloadedApp event, Emitter<DownloadState> emit) async {
    emit(Installing());
    try {
      await _downloadService.installApk(event.filePath);
      emit(InstallSuccess());
    } catch (e) {
      emit(InstallError(e.toString()));
    }
  }
}
