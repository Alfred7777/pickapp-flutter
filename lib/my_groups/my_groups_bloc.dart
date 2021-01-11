import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'my_groups_event.dart';
import 'my_groups_state.dart';
import 'package:PickApp/repositories/group_repository.dart';

class MyGroupsBloc extends Bloc<MyGroupsEvent, MyGroupsState> {
  final GroupRepository groupRepository;

  MyGroupsBloc({
    @required this.groupRepository,
  }) : assert(groupRepository != null);

  @override
  MyGroupsState get initialState => MyGroupsUninitialized();

  @override
  Stream<MyGroupsState> mapEventToState(MyGroupsEvent event) async* {
    if (event is FetchMyGroups) {
      yield MyGroupsLoading();
      try {
        var _myGroups = await groupRepository.getMyGroups();
        var _groupInvitations = await groupRepository.getGroupInvitations();

        yield MyGroupsReady(
          myGroups: _myGroups,
          groupInvitations: _groupInvitations,
        );
      } catch (exception) {
        yield FetchGroupsFailure(error: exception.message);
      }
    }
    if (event is AnswerInvitation) {
      try {
        if (event.answer == 'accept') {
          await groupRepository.answerInvitation(event.invitation, 'accept');
        } else {
          await groupRepository.answerInvitation(event.invitation, 'reject');
        }
        yield MyGroupsUninitialized();
      } catch (exception) {
        yield AnswerInvitationFailure(
          error: exception.message,
        );
        yield MyGroupsReady(
          myGroups: event.myGroups,
          groupInvitations: event.groupInvitations,
        );
      }
    }
  }
}
