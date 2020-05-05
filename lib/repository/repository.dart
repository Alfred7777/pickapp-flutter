import '../profile/profile_model.dart';
import '../profile/profile_api_provider.dart';

class Repository {
  ProfileApiProvider profileApiProvider = ProfileApiProvider();
  String user_id = 'e1d8b155-7afc-4d45-9502-9016d17fb346';
  Future<Profile> fetchProfile() => profileApiProvider.fetchProfile(user_id);
}
