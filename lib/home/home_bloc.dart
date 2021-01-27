import 'package:bloc/bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'package:PickApp/repositories/authentication_repository.dart';
import 'package:PickApp/utils/unread_notifications_count_socket.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  @override
  HomeState get initialState => HomeInitial();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is ConnectNotificationsSocket) {
      yield HomeLoading();
      var _authToken = await AuthenticationRepository.getAuthToken();

      var unreadNotificationsCountSocket = UnreadNotificationsCountSocket(
        authToken: _authToken,
        handleNewNotificationsCount: event.handleNewNotificationsCount,
      );

      await unreadNotificationsCountSocket.connect();

      yield HomeReady(
        unreadNotificationsCount: 0,
        index: 0,
      );
    }
    if (event is UpdateUnreadNotificationsCount) {
      yield HomeReady(
        index: event.index,
        unreadNotificationsCount: event.newUnreadNotificationsCount,
      );
    }
    if (event is IndexChanged) {
      yield HomeReady(
        index: event.newIndex,
        unreadNotificationsCount: event.unreadNotificationsCount,
      );
    }
  }
}
