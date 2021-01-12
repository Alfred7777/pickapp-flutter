import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'create_group_event.dart';
import 'create_group_state.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/group_repository.dart';

class CreateGroupBloc extends Bloc<CreateGroupEvent, CreateGroupState> {
  final EventRepository eventRepository;
  final GroupRepository groupRepository;

  CreateGroupBloc({
    @required this.eventRepository,
    @required this.groupRepository,
  });

  @override
  CreateGroupState get initialState => CreateGroupInitial();

  @override
  Stream<CreateGroupState> mapEventToState(CreateGroupEvent event) async* {
    if (event is FetchDisciplines) {
      try {
        yield CreateGroupLoading();

        var _disciplines = await eventRepository.getDisciplines();

        yield CreateGroupReady(
          disciplines: _disciplines,
        );
      } catch (exception) {
        yield FetchDisciplinesFailure(error: exception.message);
      }
    }
    if (event is CreateGroupButtonPressed) {
      var response = await groupRepository.createGroup(
        name: event.groupName,
        description: event.groupDescription,
        disciplineID: event.groupDisciplineID,
      );
      if (response == 'Group successfully created.') {
        yield CreateGroupCreated(
          message: response,
        );
      } else {
        yield CreateGroupFailure(
          disciplines: event.disciplines,
          error: response,
        );
      }
      yield CreateGroupReady(
        disciplines: event.disciplines,
      );
    }
  }
}
