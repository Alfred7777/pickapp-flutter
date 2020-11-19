import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../push_notifications.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';
import 'package:PickApp/repositories/userRepository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AppStarted) {
      final hasToken = await userRepository.hasToken();

      if (hasToken) {
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistToken(event.authResponse);
      unawaited(assignExternalUserIDForPushNotifications(event.authResponse));
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }
  }

  Future<void> assignExternalUserIDForPushNotifications(
      String authResponse) async {
    var userID = json.decode(authResponse)['user_id'];
    unawaited(PushNotifications.assignExternalUserID(userID));
  }

  static void unawaited(Future<void> future) {}
}
