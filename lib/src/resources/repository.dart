import '../models/profile_model.dart';
import 'profile_api_provider.dart';

class Repository {
  ProfileApiProvider profileApiProvider = ProfileApiProvider();

  Future<Profile> fetchProfile() => profileApiProvider.fetchProfile();
}
