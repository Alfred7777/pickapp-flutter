import 'package:PickApp/home/home_bloc.dart';
import 'package:PickApp/home/home_event.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/widgets/bottom_navbar/unread_notifications_count_socket.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'bottom_navbar_event.dart';
import 'bottom_navbar_state.dart';

class BottomNavbarBloc extends Bloc<BottomNavbarEvent, BottomNavbarState> {
  final UserRepository userRepository;
  final HomeBloc homeBloc;

  BottomNavbarBloc({@required this.userRepository, @required this.homeBloc});

  @override
  BottomNavbarState get initialState => InitialBottomNavbarState();

  @override
  Stream<BottomNavbarState> mapEventToState(BottomNavbarEvent event) async* {
    if (event is InitializeBottomNavbar) {
      var authToken = await (userRepository.getAuthToken());
      var unreadNotificationsCountSocket = UnreadNotificationsCountSocket(
        authToken: authToken,
        bottomNavbarBloc: this,
      );

      unawaited(unreadNotificationsCountSocket.connect());
    }
    if (event is NotificationsCountUpdated) {
      yield BottomNavbarLoaded(
          index: state.index,
          currentUnreadNotificationsCount: event.newUnreadNotificationsCount);
      return;
    }
    if (event is IndexChanged) {
      homeBloc.add(NavbarSelectedIndexChanged(index: event.index));
      yield BottomNavbarLoaded(
        index: event.index,
        currentUnreadNotificationsCount: event.currentUnreadNotificationsCount,
      );
      return;
    }
  }

  static void unawaited(Future<void> future) {}
}
