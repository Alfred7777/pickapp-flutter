import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'group_invitation_event.dart';
import 'group_invitation_state.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class GroupInvitationBloc
    extends Bloc<GroupInvitationEvent, GroupInvitationState> {
  final GroupRepository groupRepository;
  final UserRepository userRepository;
  final String groupID;

  GroupInvitationBloc({
    @required this.groupRepository,
    @required this.userRepository,
    @required this.groupID,
  });

  @override
  GroupInvitationState get initialState =>
      GroupInvitationUninitialized(groupID: groupID);

  @override
  Stream<GroupInvitationState> mapEventToState(
      GroupInvitationEvent event) async* {
    if (event is SearchRequested) {
      yield GroupInvitationSearchInProgress(query: event.query);
      try {
        var searchResult = await userRepository.searchUser(event.query);
        yield GroupInvitationSearchCompleted(
          query: event.query,
          searchResult: searchResult,
        );
      } catch (error) {
        yield GroupInvitationFailure(error: error.message);
        yield GroupInvitationSearchCompleted(
          query: event.query,
          searchResult: [],
        );
      }
    }
    if (event is InviteButtonPressed) {
      try {
        var response = await groupRepository.inviteToGroup(
          event.groupID,
          event.inviteeID,
        );
        yield GroupInvitationInvited(
          message: response,
          inviteeID: event.inviteeID,
        );
      } catch (error) {
        yield GroupInvitationFailure(error: error.message);
      }
      yield GroupInvitationSearchCompleted(
        query: event.query,
        searchResult: event.searchResults,
      );
    }
  }
}
