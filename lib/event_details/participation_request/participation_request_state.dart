import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/event_repository.dart';

class ParticipationRequestState extends Equatable {
  const ParticipationRequestState();

  @override
  List<Object> get props => [];
}

class ParticipationRequestUninitialized extends ParticipationRequestState {
  final String eventID;

  const ParticipationRequestUninitialized({@required this.eventID});
}

class ParticipationRequestLoading extends ParticipationRequestState {}

class ParticipationRequestReady extends ParticipationRequestState {
  final List<ParticipationRequest> participationRequestList;

  const ParticipationRequestReady({
    @required this.participationRequestList,
  });

  @override
  List<Object> get props => [participationRequestList];
}

class FetchParticipationRequestsFailure extends ParticipationRequestState {
  final String error;

  const FetchParticipationRequestsFailure({@required this.error});

  @override
  List<Object> get props => [error];
}

class AnswerParticipationRequestFailure extends ParticipationRequestState {
  final String error;

  const AnswerParticipationRequestFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
