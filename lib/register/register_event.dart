import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class CreateAccountButtonPressed extends RegisterEvent {
  final String email;
  final String password;

  const CreateAccountButtonPressed({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
