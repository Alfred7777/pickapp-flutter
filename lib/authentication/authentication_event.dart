import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String authResponse;

  const LoggedIn({@required this.authResponse});

  @override
  List<Object> get props => [authResponse];
}

class LoggedOut extends AuthenticationEvent {}
