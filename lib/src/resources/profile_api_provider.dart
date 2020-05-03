import 'dart:convert';
import 'package:http/http.dart' show Client;
import '../models/profile_model.dart';

class ProfileApiProvider {
  Client client = Client();
  final _url = 'http://localhost:4000/api/profile/';

  Future<Profile> fetchProfile() async {
    var id = '5240ed16-1b23-485a-974c-cfb40896e432';
    var response = await client.get(_url + id);

    if (response.statusCode == 200) {
      return Profile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
