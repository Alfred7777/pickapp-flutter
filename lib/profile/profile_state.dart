import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/user_repository.dart';

class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileUninitialized extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileReady extends ProfileState {
  final User details;
  final Map<String, dynamic> stats;
  final String pictureUploadUrl;
  final Map<dynamic, dynamic> rating;

  const ProfileReady({
    @required this.details,
    @required this.stats,
    @required this.pictureUploadUrl,
    @required this.rating,
  });

  @override
  List<Object> get props => [details, stats, pictureUploadUrl, rating];
}

class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
