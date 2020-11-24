import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';
import 'package:PickApp/repositories/notificationRepository.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository notificationRepository;

  NotificationsBloc({
    @required this.notificationRepository,
  }) : assert(notificationRepository != null);

  @override
  NotificationsState get initialState => NotificationsUninitialized();

  @override
  Stream<NotificationsState> mapEventToState(NotificationsEvent event) async* {
    if (event is FetchNotifications) {
      yield NotificationsLoading();
      try {
        var _notifications = await notificationRepository.getNotifications(
          event.nextToken,
        );

        yield NotificationsReady(
          nextToken: _notifications['next_token'],
          notifications: event.notifications + _notifications['notifications'],
        );
      } catch (exception) {
        yield FetchNotificationsFailure(error: exception.message);
      }
    }
  }
}