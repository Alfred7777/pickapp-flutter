import '../profile/profile_model.dart';
import '../profile/profile_api_provider.dart';

class Repository {
  ProfileApiProvider profileApiProvider = ProfileApiProvider();
  String user_id = 'de9ac1c2-37e8-4244-9bc5-a6026c0ab717';
  Future<Profile> fetchProfile() => profileApiProvider.fetchProfile(user_id);
}
