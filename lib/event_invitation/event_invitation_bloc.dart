import 'event_invitation_event.dart';
import 'event_invitation_state.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:PickApp/repositories/userRepository.dart';

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
    if (event is InviteButtonPressed) {
      try {
        var response = await eventRepository.inviteToEvent(
          event.eventID,
          event.inviteeID,
        );
        yield EventInvitationInvited(message: response);
      } catch (error) {
        yield EventInvitationFailure(error: error.message);
      }
    }
    if (event is SearchButtonPressed) {
      try {
        var searchResult = await userRepository.searchUser(event.searchPhrase);
        yield EventInvitationUninitialized(eventID: eventID);
        yield EventInvitationSearchPerformed(searchResult: searchResult);
      } catch (error) {
        yield EventInvitationFailure(error: error.message);
      }
    }
  }
}
