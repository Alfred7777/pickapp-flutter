import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;

  const LoginButtonPressed({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignInWithFacebookButtonPressed extends LoginEvent {
  const SignInWithFacebookButtonPressed();

  @override
  List<Object> get props => [];
}
