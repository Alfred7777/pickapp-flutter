import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class EventRatingState extends Equatable {
  const EventRatingState();

  @override
  List<Object> get props => [];
}

class EventRatingUnconnected extends EventRatingState {}

class EventRatingUninitialized extends EventRatingState {}

class EventRatingInitialized extends EventRatingState {
  final Map<User, bool> usersRating;
  final List<User> participants;
  final Event event;

  const EventRatingInitialized({
    @required this.usersRating,
    @required this.participants,
    @required this.event,
  });

  @override
  List<Object> get props => [
        usersRating,
        participants,
        event,
      ];
}

class EventRatingFinished extends EventRatingState {}

class EventRatingFailure extends EventRatingState {
  final String error;

  const EventRatingFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
