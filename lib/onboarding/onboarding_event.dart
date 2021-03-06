import 'package:PickApp/repositories/user_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class CheckIfOnboardingCompleted extends OnboardingEvent {}

class FetchProfileDraft extends OnboardingEvent {}

class SubmitForm extends OnboardingEvent {
  final String name;
  final String uniqueUsername;
  final String bio;
  final String profilePicturePath;
  final ProfileDraft draft;

  const SubmitForm({
    @required this.name,
    @required this.uniqueUsername,
    @required this.bio,
    @required this.draft,
    @required this.profilePicturePath,
  });

  @override
  List<Object> get props => [
        name,
        uniqueUsername,
        bio,
        profilePicturePath,
        draft,
      ];
}

class CompleteOnboarding extends OnboardingEvent {}
