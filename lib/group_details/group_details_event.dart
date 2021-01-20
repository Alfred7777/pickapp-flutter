import 'package:equatable/equatable.dart';

class GroupDetailsEvent extends Equatable {
  const GroupDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchGroupDetails extends GroupDetailsEvent {
  const FetchGroupDetails();

  @override
  List<Object> get props => [];
}

class RemoveUser extends GroupDetailsEvent {
  final String userID;

  const RemoveUser(
    this.userID,
  );

  @override
  List<Object> get props => [userID];
}

class LeaveGroup extends GroupDetailsEvent {
  const LeaveGroup();

  @override
  List<Object> get props => [];
}

class DeleteGroup extends GroupDetailsEvent {
  const DeleteGroup();

  @override
  List<Object> get props => [];
}
