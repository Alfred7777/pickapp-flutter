import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/notification_repository.dart';

class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class FetchNotifications extends NotificationsEvent {
  final String nextToken;
  final List<Notification> notifications;
  final int limit;

  const FetchNotifications({
    @required this.nextToken,
    @required this.notifications,
    @required this.limit,
  });
}
