import 'package:PickApp/repositories/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:PickApp/authentication/authentication_event.dart';
import 'package:PickApp/authentication/authentication_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.authenticationBloc,
  }) : assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final authResponse = await AuthenticationRepository.signInWithEmail(
          email: event.email,
          password: event.password,
        );
        authenticationBloc.add(LoggedInByEmail(authResponse: authResponse));
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: 'Invalid credentials');
      }
    }
    if (event is SignInWithFacebookButtonPressed) {
      yield LoginLoading();

      try {
        var response = await AuthenticationRepository.signInWithFacebook();
        authenticationBloc.add(LoggedInByFacebook(
          authToken: response['authToken'],
          userData: response['userData'],
          fbAuthToken: response['fbAuthToken'],
          userId: response['userId'],
        ));
      } catch (error) {
        yield LoginFailure(error: error.message);
      }
    }
  }
}
