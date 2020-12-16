import 'participation_request_event.dart';
import 'participation_request_state.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:PickApp/repositories/event_repository.dart';

class ParticipationRequestBloc
    extends Bloc<ParticipationRequestEvent, ParticipationRequestState> {
  final EventRepository eventRepository;
  final String eventID;

  ParticipationRequestBloc({
    @required this.eventRepository,
    @required this.eventID,
  });

  @override
  ParticipationRequestState get initialState =>
      ParticipationRequestUninitialized(eventID: eventID);

  @override
  Stream<ParticipationRequestState> mapEventToState(
      ParticipationRequestEvent event) async* {
    if (event is FetchParticipationRequests) {
      yield ParticipationRequestLoading();
      try {
        var _participationRequestList =
            await eventRepository.getParticipationRequests(event.eventID);
        yield ParticipationRequestReady(
          participationRequestList: _participationRequestList,
        );
      } catch (error) {
        yield FetchParticipationRequestsFailure(error: error.message);
      }
    }
    if (event is AcceptParticipant) {
      try {
        await eventRepository.answerParticipationRequest(
          event.eventID,
          event.requesterID,
          'accept',
        );
      } catch (error) {
        yield AnswerParticipationRequestFailure(error: error.message);
      }
    }
    if (event is RejectParticipant) {
      try {
        await eventRepository.answerParticipationRequest(
          event.eventID,
          event.requesterID,
          'reject',
        );
      } catch (error) {
        yield AnswerParticipationRequestFailure(error: error.message);
      }
    }
  }
}
