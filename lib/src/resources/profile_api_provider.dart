import 'dart:convert';
import 'package:http/http.dart' show Client;
import '../models/profile_model.dart';

class ProfileApiProvider{
  Client client = Client();
  final _url = 'http://localhost:4000/api/profile/bb90cb80-b971-4072-be50-402389a8abb7';

  Future<Profile> fetchProfile() async{
    final response = await client.get(_url);
    print(response.body.toString());

    if (response.statusCode == 200){
      return Profile.fromJson(json.decode(response.body));
    }
    else{
      throw Exception('Failed to load profile');
    }
  }
}