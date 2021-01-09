import 'package:PickApp/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc();

  @override
  OnboardingState get initialState => OnboardingInitial();

  @override
  Stream<OnboardingState> mapEventToState(OnboardingEvent event) async* {
    if (event is CheckIfOnboardingCompleted) {
      yield OnboardingLoading();
      if (await UserRepository.isOnboardingCompleted()) {
        yield OnboardingCompleted();
      } else {
        yield OnboardingRequired();
      }
    }
    if (event is FetchProfileDraft) {
      yield OnboardingLoading();
      try {
        var draft = await UserRepository.getProfileDraft();
        yield OnboardingLoaded(draft: draft);
      } catch (error) {
        yield ProfileDraftFetchFailure(error: error.message);
      }
    }

    if (event is SubmitForm) {
      yield OnboardingLoading();
      var params = {
        'name': event.name,
        'unique_username': event.uniqueUsername,
        'bio': event.bio
      };
      try {
        await UserRepository.createProfile(params);
        yield OnboardingCompleted();
      } catch (error) {
        yield ProfileCreationFailure(error: error.message, draft: event.draft);
      }
    }
  }
}
