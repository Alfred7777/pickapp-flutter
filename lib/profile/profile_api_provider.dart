import 'dart:convert';
import 'package:PickApp/client.dart';
import 'package:PickApp/profile/profile_model.dart';

class ProfileApiProvider {
  var client = AuthenticatedApiClient();
  Future<Profile> fetchProfile(String id) async {
    final response = await client.get('profile/' + id);

    if (response.statusCode == 200) {
      return Profile.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load profile' + (response.statusCode).toString());
    }
  }
}
