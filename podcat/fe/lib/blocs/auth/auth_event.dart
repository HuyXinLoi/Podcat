part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuth extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String password;

  const RegisterRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class LogoutRequested extends AuthEvent {}

class LoadUserProfile extends AuthEvent {}

class UpdateUserProfile extends AuthEvent {
  final Map<String, dynamic> profileData;

  const UpdateUserProfile({required this.profileData});

  @override
  List<Object> get props => [profileData];
}
