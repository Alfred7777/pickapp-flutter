import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/repositories/group_repository.dart';

class GroupDetailsState extends Equatable {
  const GroupDetailsState();

  @override
  List<Object> get props => [];
}

class GroupDetailsUninitialized extends GroupDetailsState {
  final String groupID;

  const GroupDetailsUninitialized({@required this.groupID});
}

class GroupDetailsLoading extends GroupDetailsState {}

class GroupDetailsReady extends GroupDetailsState {
  final String groupID;
  final Group groupDetails;
  final List<GroupPost> postList;
  final List<User> memberList;

  const GroupDetailsReady({
    @required this.groupID,
    @required this.groupDetails,
    @required this.postList,
    @required this.memberList,
  });
}

class GroupDetailsGroupDeleted extends GroupDetailsState {}

class GroupDetailsGroupLeft extends GroupDetailsState {}

class GroupDetailsFailure extends GroupDetailsState {
  final String error;

  const GroupDetailsFailure({@required this.error});
}
