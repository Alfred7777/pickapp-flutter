import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedInByEmail extends AuthenticationEvent {
  final String authResponse;

  const LoggedInByEmail({@required this.authResponse});

  @override
  List<Object> get props => [authResponse];
}

class LoggedInByFacebook extends AuthenticationEvent {
  final String authToken;
  final Map<String, dynamic> userData;
  final String fbAuthToken;
  final String userId;

  const LoggedInByFacebook({
    @required this.authToken,
    @required this.userData,
    @required this.fbAuthToken,
    @required this.userId,
  });

  @override
  List<Object> get props => [
        authToken,
        userData,
        fbAuthToken,
        userId,
      ];
}

class LoggedOut extends AuthenticationEvent {}
