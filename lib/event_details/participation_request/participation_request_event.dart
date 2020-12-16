import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class ParticipationRequestEvent extends Equatable {
  const ParticipationRequestEvent();

  @override
  List<Object> get props => [];
}

class FetchParticipationRequests extends ParticipationRequestEvent {
  final String eventID;

  const FetchParticipationRequests({
    @required this.eventID,
  });

  @override
  List<Object> get props => [eventID];
}

class AcceptParticipant extends ParticipationRequestEvent {
  final String eventID;
  final String requesterID;

  const AcceptParticipant({
    @required this.eventID,
    @required this.requesterID,
  });

  @override
  List<Object> get props => [eventID, requesterID];
}

class RejectParticipant extends ParticipationRequestEvent {
  final String eventID;
  final String requesterID;

  const RejectParticipant({
    @required this.eventID,
    @required this.requesterID,
  });

  @override
  List<Object> get props => [eventID, requesterID];
}
