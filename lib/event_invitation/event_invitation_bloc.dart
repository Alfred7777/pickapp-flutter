import 'event_invitation_event.dart';
import 'event_invitation_state.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class EventInvitationBloc
    extends Bloc<EventInvitationEvent, EventInvitationState> {
  final EventRepository eventRepository;
  final UserRepository userRepository;
  final String eventID;

  EventInvitationBloc({
    @required this.eventRepository,
    @required this.userRepository,
    @required this.eventID,
  });

  @override
  EventInvitationState get initialState =>
      EventInvitationUninitialized(eventID: eventID);

  @override
  Stream<EventInvitationState> mapEventToState(
      EventInvitationEvent event) async* {
    if (event is SearchRequested) {
      yield EventInvitationSearchInProgress(query: event.query);
      try {
        var searchResult = await userRepository.searchUser(event.query);
        yield EventInvitationSearchCompleted(
          query: event.query,
          searchResult: searchResult,
        );
      } catch (error) {
        yield EventInvitationFailure(error: error.message);
        yield EventInvitationSearchCompleted(
          query: event.query,
          searchResult: [],
        );
      }
    }
    if (event is InviteButtonPressed) {
      try {
        var response = await eventRepository.inviteToEvent(
          event.eventID,
          event.inviteeID,
        );
        yield EventInvitationInvited(
          message: response,
          inviteeID: event.inviteeID,
        );
      } catch (error) {
        yield EventInvitationFailure(error: error.message);
      }
      yield EventInvitationSearchCompleted(
        query: event.query,
        searchResult: event.searchResults,
      );
    }
  }
}
