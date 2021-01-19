import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/user_repository.dart';

class ProfileUpdateEvent extends Equatable {
  const ProfileUpdateEvent();

  @override
  List<Object> get props => [];
}

class FetchInitialDetails extends ProfileUpdateEvent {
  final String userID;

  const FetchInitialDetails({
    @required this.userID,
  });

  @override
  List<Object> get props => [userID];
}

class UpdateProfileButtonPressed extends ProfileUpdateEvent {
  final String name;
  final String bio;
  final User initialDetails;

  UpdateProfileButtonPressed({
    @required this.name,
    @required this.bio,
    @required this.initialDetails,
  });

  @override
  List<Object> get props => [
        name,
        bio,
        initialDetails,
      ];
}
