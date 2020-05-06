import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:PickApp/authentication/authentication_event.dart';
import 'package:PickApp/authentication/authentication_bloc.dart';
import 'package:PickApp/repositories/userRepository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  }): assert(userRepository != null), assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if(event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final token = await userRepository.authenticate(
          email: event.email,
          password: event.password
        );
        authenticationBloc.add(LoggedIn(token: token));
        yield LoginInitial();
      } 
      catch (error) {
        yield LoginFailure(error: 'Invalid credentials');
      }
    }
  }
}