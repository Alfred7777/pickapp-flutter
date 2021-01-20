import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class PostDetailsEvent extends Equatable {
  const PostDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchPostAnswers extends PostDetailsEvent {
  final String postID;

  const FetchPostAnswers({
    @required this.postID,
  });

  @override
  List<Object> get props => [postID];
}

class AddAnswerButtonPressed extends PostDetailsEvent {
  final String content;

  const AddAnswerButtonPressed({
    @required this.content,
  });

  @override
  List<Object> get props => [content];
}
