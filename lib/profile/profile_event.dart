import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchProfile extends ProfileEvent {
  final String userID;

  const FetchProfile({@required this.userID});

  @override
  List<Object> get props => [userID];
}
