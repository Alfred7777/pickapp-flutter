import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/user_repository.dart';

class ProfileUpdateState extends Equatable {
  const ProfileUpdateState();

  @override
  List<Object> get props => [];
}

class ProfileUpdateUninitialized extends ProfileUpdateState {
  final String userID;

  const ProfileUpdateUninitialized({
    @required this.userID,
  });

  @override
  List<Object> get props => [userID];
}

class ProfileUpdateLoading extends ProfileUpdateState {}

class ProfileUpdateReady extends ProfileUpdateState {
  final User initialDetails;

  const ProfileUpdateReady({
    @required this.initialDetails,
  });

  @override
  List<Object> get props => [initialDetails];
}

class ProfileUpdateSuccess extends ProfileUpdateState {
  final String message;

  const ProfileUpdateSuccess({@required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileUpdateFailure extends ProfileUpdateState {
  final String error;

  const ProfileUpdateFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
