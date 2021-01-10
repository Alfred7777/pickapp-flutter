import 'package:PickApp/home/home_screen.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_form.dart';
import 'onboarding_state.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen();

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  _OnboardingScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider<OnboardingBloc>(
          create: (BuildContext context) => OnboardingBloc(),
          child: BlocListener<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              if (state is ProfileCreationFailure) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<OnboardingBloc, OnboardingState>(
              builder: (context, state) {
                if (state is OnboardingInitial) {
                  BlocProvider.of<OnboardingBloc>(
                    context,
                  ).add(
                    CheckIfOnboardingCompleted(),
                  );
                }
                if (state is OnboardingRequired) {
                  BlocProvider.of<OnboardingBloc>(
                    context,
                  ).add(
                    FetchProfileDraft(),
                  );
                }
                if (state is OnboardingLoading) {
                  return LoadingScreen();
                }
                if (state is OnboardingLoaded) {
                  return OnboardingForm(profileDraft: state.draft);
                }
                if (state is ProfileCreationFailure) {
                  return OnboardingForm(profileDraft: state.draft);
                }
                if (state is OnboardingCompleted) {
                  return HomeScreen();
                }
                if (state is ProfileDraftFetchFailure) {
                  return Center(
                    child: Text(
                      'Something went terribly wrong. Please try again later or contact our support.',
                    ),
                  );
                }
                return LoadingScreen();
              },
            ),
          ),
        ),
      ),
    );
  }
}
