import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/user_repository.dart';

class AddPostState extends Equatable {
  const AddPostState();

  @override
  List<Object> get props => [];
}

class AddPostUninitialized extends AddPostState {
  final String groupID;

  const AddPostUninitialized({@required this.groupID});
}

class AddPostReady extends AddPostState {
  final String groupID;
  final User author;

  const AddPostReady({
    @required this.groupID,
    @required this.author,
  });
}

class AddPostCreated extends AddPostState {
  final String message;

  const AddPostCreated({@required this.message});

  @override
  List<Object> get props => [message];
}

class AddPostFailure extends AddPostState {
  final String error;

  const AddPostFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
