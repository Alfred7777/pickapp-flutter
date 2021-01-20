import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class AddPostEvent extends Equatable {
  const AddPostEvent();

  @override
  List<Object> get props => [];
}

class FetchAuthorProfile extends AddPostEvent {
  const FetchAuthorProfile();

  @override
  List<Object> get props => [];
}

class AddPostButtonPressed extends AddPostEvent {
  final String content;

  const AddPostButtonPressed({
    @required this.content,
  });

  @override
  List<Object> get props => [content];
}
