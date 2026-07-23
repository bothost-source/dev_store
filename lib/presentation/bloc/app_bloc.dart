import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/app_model.dart';
import '../../data/repositories/app_repository.dart';

// Events
abstract class AppEvent extends Equatable {
  const AppEvent();
  @override
  List<Object?> get props => [];
}

class LoadApps extends AppEvent {
  final String? category;
  final String? searchQuery;
  final String sortBy;
  const LoadApps({this.category, this.searchQuery, this.sortBy = 'createdAt'});
}

class LoadFeaturedApps extends AppEvent {
  const LoadFeaturedApps();
}

class LoadNewReleases extends AppEvent {
  const LoadNewReleases();
}

class LoadTopCharts extends AppEvent {
  const LoadTopCharts();
}

class LoadPendingApps extends AppEvent {
  const LoadPendingApps();
}

class LoadAppDetail extends AppEvent {
  final String appId;
  const LoadAppDetail(this.appId);
}

class LoadSimilarApps extends AppEvent {
  final String appId;
  final String category;
  const LoadSimilarApps(this.appId, this.category);
}

class LoadDeveloperApps extends AppEvent {
  final String developerId;
  const LoadDeveloperApps(this.developerId);
}

class ApproveAppEvent extends AppEvent {
  final String appId;
  const ApproveAppEvent(this.appId);
}

class RejectAppEvent extends AppEvent {
  final String appId;
  final String reason;
  const RejectAppEvent(this.appId, this.reason);
}

class ToggleFeaturedEvent extends AppEvent {
  final String appId;
  final bool isFeatured;
  const ToggleFeaturedEvent(this.appId, this.isFeatured);
}

class DeleteAppEvent extends AppEvent {
  final String appId;
  const DeleteAppEvent(this.appId);
}

// States
abstract class AppState extends Equatable {
  const AppState();
  @override
  List<Object?> get props => [];
}

class AppInitial extends AppState {}
class AppLoading extends AppState {}
class AppsLoaded extends AppState {
  final List<AppModel> apps;
  const AppsLoaded(this.apps);
  @override
  List<Object?> get props => [apps];
}

class AppDetailLoaded extends AppState {
  final AppModel app;
  final List<AppModel> similarApps;
  const AppDetailLoaded(this.app, {this.similarApps = const []});
  @override
  List<Object?> get props => [app, similarApps];
}

class AppOperationSuccess extends AppState {
  final String message;
  const AppOperationSuccess(this.message);
}

class AppError extends AppState {
  final String message;
  const AppError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AppBloc extends Bloc<AppEvent, AppState> {
  final AppRepository _repository;

  AppBloc(this._repository) : super(AppInitial()) {
    on<LoadApps>(_onLoadApps);
    on<LoadFeaturedApps>(_onLoadFeaturedApps);
    on<LoadNewReleases>(_onLoadNewReleases);
    on<LoadTopCharts>(_onLoadTopCharts);
    on<LoadPendingApps>(_onLoadPendingApps);
    on<LoadAppDetail>(_onLoadAppDetail);
    on<LoadSimilarApps>(_onLoadSimilarApps);
    on<LoadDeveloperApps>(_onLoadDeveloperApps);
    on<ApproveAppEvent>(_onApproveApp);
    on<RejectAppEvent>(_onRejectApp);
    on<ToggleFeaturedEvent>(_onToggleFeatured);
    on<DeleteAppEvent>(_onDeleteApp);
  }

  Future<void> _onLoadApps(LoadApps event, Emitter<AppState> emit) async {
    emit(AppLoading());
    await emit.forEach(
      _repository.getApprovedApps(
        category: event.category,
        searchQuery: event.searchQuery,
        sortBy: event.sortBy,
      ),
      onData: (apps) => AppsLoaded(apps),
      onError: (error, stackTrace) => AppError(error.toString()),
    );
  }

  Future<void> _onLoadFeaturedApps(LoadFeaturedApps event, Emitter<AppState> emit) async {
    emit(AppLoading());
    await emit.forEach(
      _repository.getFeaturedApps(),
      onData: (apps) => AppsLoaded(apps),
      onError: (error, stackTrace) => AppError(error.toString()),
    );
  }

  Future<void> _onLoadNewReleases(LoadNewReleases event, Emitter<AppState> emit) async {
    emit(AppLoading());
    await emit.forEach(
      _repository.getNewReleases(),
      onData: (apps) => AppsLoaded(apps),
      onError: (error, stackTrace) => AppError(error.toString()),
    );
  }

  Future<void> _onLoadTopCharts(LoadTopCharts event, Emitter<AppState> emit) async {
    emit(AppLoading());
    await emit.forEach(
      _repository.getTopCharts(),
      onData: (apps) => AppsLoaded(apps),
      onError: (error, stackTrace) => AppError(error.toString()),
    );
  }

  Future<void> _onLoadPendingApps(LoadPendingApps event, Emitter<AppState> emit) async {
    emit(AppLoading());
    await emit.forEach(
      _repository.getPendingApps(),
      onData: (apps) => AppsLoaded(apps),
      onError: (error, stackTrace) => AppError(error.toString()),
    );
  }

  Future<void> _onLoadAppDetail(LoadAppDetail event, Emitter<AppState> emit) async {
    emit(AppLoading());
    try {
      final app = await _repository.getAppById(event.appId);
      if (app != null) {
        final similarApps = await _repository.getSimilarApps(event.appId, app.category);
        emit(AppDetailLoaded(app, similarApps: similarApps));
      } else {
        emit(const AppError('App not found'));
      }
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> _onLoadSimilarApps(LoadSimilarApps event, Emitter<AppState> emit) async {
    emit(AppLoading());
    try {
      final apps = await _repository.getSimilarApps(event.appId, event.category);
      emit(AppsLoaded(apps));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> _onLoadDeveloperApps(LoadDeveloperApps event, Emitter<AppState> emit) async {
    emit(AppLoading());
    await emit.forEach(
      _repository.getDeveloperApps(event.developerId),
      onData: (apps) => AppsLoaded(apps),
      onError: (error, stackTrace) => AppError(error.toString()),
    );
  }

  Future<void> _onApproveApp(ApproveAppEvent event, Emitter<AppState> emit) async {
    try {
      await _repository.approveApp(event.appId);
      emit(const AppOperationSuccess('App approved successfully'));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> _onRejectApp(RejectAppEvent event, Emitter<AppState> emit) async {
    try {
      await _repository.rejectApp(event.appId, event.reason);
      emit(const AppOperationSuccess('App rejected'));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> _onToggleFeatured(ToggleFeaturedEvent event, Emitter<AppState> emit) async {
    try {
      await _repository.toggleFeatured(event.appId, event.isFeatured);
      emit(const AppOperationSuccess('Featured status updated'));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> _onDeleteApp(DeleteAppEvent event, Emitter<AppState> emit) async {
    try {
      await _repository.deleteApp(event.appId);
      emit(const AppOperationSuccess('App deleted'));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }
}
