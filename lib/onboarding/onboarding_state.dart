import 'package:PickApp/repositories/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingLoaded extends OnboardingState {
  final ProfileDraft draft;

  const OnboardingLoaded({@required this.draft});

  @override
  List<Object> get props => [draft];
}

class OnboardingRequired extends OnboardingState {}

class OnboardingCompleted extends OnboardingState {}

class ProfileDraftFetchFailure extends OnboardingState {
  final String error;

  const ProfileDraftFetchFailure({@required this.error});

  @override
  List<Object> get props => [error];
}

class ProfileCreationFailure extends OnboardingState {
  final String error;
  final ProfileDraft draft;

  const ProfileCreationFailure({@required this.error, @required this.draft});

  @override
  List<Object> get props => [error, draft];
}
