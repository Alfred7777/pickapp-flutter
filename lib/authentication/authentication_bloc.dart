import 'dart:convert';
import 'package:PickApp/repositories/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import '../push_notifications.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AppStarted) {
      final hasToken = await AuthenticationRepository.hasToken();

      if (hasToken) {
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedInByEmail) {
      var userID = json.decode(event.authResponse)['user_id'];
      var authToken = (json.decode(event.authResponse))['auth_token'];

      yield AuthenticationLoading();
      initializeSession(userID, authToken);
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedInByFacebook) {
      yield AuthenticationLoading();
      initializeSession(event.userId, event.authToken);
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await AuthenticationRepository.deleteToken();
      await AuthenticationRepository.logOutWithFb();
      yield AuthenticationUnauthenticated();
    }
  }

  void initializeSession(String userID, String authToken) async {
    await AuthenticationRepository.persistToken(authToken);
    unawaited(PushNotifications.assignExternalUserID(userID));
  }

  static void unawaited(Future<void> future) {}
}
