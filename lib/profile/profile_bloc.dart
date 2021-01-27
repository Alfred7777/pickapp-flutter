import 'package:PickApp/profile/profile_event.dart';
import 'package:PickApp/profile/profile_state.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;
  final String userID;

  ProfileBloc({
    @required this.userRepository,
    @required this.userID,
  }) : assert(userRepository != null);

  @override
  ProfileState get initialState => ProfileUninitialized();

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    try {
      yield ProfileLoading();

      if (event is UpdateProfilePicture) {
        await userRepository.uploadNewProfilePicture(
          event.pictureUploadUrl,
          event.pickedProfilePicture,
        );
      }

      var _details = await userRepository.getProfileDetails(userID);
      var _stats = await userRepository.getUserStats(userID);
      var _uploadUrl = await userRepository.getProfilePictureUploadUrl();
      var _rating = await UserRepository.getUserRating(userID);

      yield ProfileReady(
        details: _details,
        stats: _stats,
        pictureUploadUrl: _uploadUrl,
        rating: _rating,
      );
    } catch (exception) {
      yield ProfileFailure(
        error: exception.message,
      );
    }
  }
}
