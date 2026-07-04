import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}
class LoggedIn extends AuthEvent {
  final UserModel user;
  const LoggedIn(this.user);
}
class LoggedOut extends AuthEvent {}
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final bool isDeveloper;
  const SignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
    this.isDeveloper = false,
  });
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested({required this.email, required this.password});
}

class SignOutRequested extends AuthEvent {}
class BecomeDeveloperRequested extends AuthEvent {
  final Map<String, dynamic> profile;
  const BecomeDeveloperRequested(this.profile);
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthSuccess extends AuthState {
  final String message;
  const AuthSuccess(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignUpRequested>(_onSignUp);
    on<SignInRequested>(_onSignIn);
    on<SignOutRequested>(_onSignOut);
    on<BecomeDeveloperRequested>(_onBecomeDeveloper);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        if (userData != null) {
          emit(Authenticated(userData));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        isDeveloper: event.isDeveloper,
      );
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Failed to create account'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signIn(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Failed to sign in'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authService.signOut();
    emit(Unauthenticated());
  }

  Future<void> _onBecomeDeveloper(BecomeDeveloperRequested event, Emitter<AuthState> emit) async {
    try {
      final currentState = state;
      if (currentState is Authenticated) {
        await _authService.updateUser(currentState.user.uid, {
          'isDeveloper': true,
          'role': 'developer',
          'developerProfile': event.profile,
        });
        final updatedUser = currentState.user.copyWith(
          isDeveloper: true,
          role: 'developer',
          developerProfile: event.profile != null 
          ? DeveloperProfile.fromMap(event.profile as Map<String, dynamic>) 
         : null,
        );
        emit(Authenticated(updatedUser));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

extension on UserModel {
  UserModel copyWith({bool? isDeveloper, String? role, DeveloperProfile? developerProfile}) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      role: role ?? this.role,
      isDeveloper: isDeveloper ?? this.isDeveloper,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      installedApps: installedApps,
      favoriteApps: favoriteApps,
      developerProfile: developerProfile ?? this.developerProfile,
    );
  }
}
