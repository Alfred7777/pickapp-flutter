import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import './profile_model.dart';

class ProfileApiProvider {
  //Client client = Client();
  final _url = 'http://150.254.78.200/api/profile/';

  Future<Profile> fetchProfile(String id) async {
    final response = await http.get(_url + id, headers: {
      HttpHeaders.authorizationHeader:
          'Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRoZW50aWNhdGlvbiIsImV4cCI6MTU5MTA0MTMzMywiaWF0IjoxNTg4NjIyMTMzLCJpc3MiOiJhdXRoZW50aWNhdGlvbiIsImp0aSI6ImM2NTRiMWMxLTEyNDYtNDdmMC05NTcwLWQxNjRiOThhYThlNCIsIm5iZiI6MTU4ODYyMjEzMiwic3ViIjoiZTFkOGIxNTUtN2FmYy00ZDQ1LTk1MDItOTAxNmQxN2ZiMzQ2IiwidHlwIjoiYWNjZXNzIn0.y1OtUD4CJtVFkFvcmq_7311B9WdwWyq73_bISiwoTUB1YsaMkIOOYWnQDVfuNYLnDPHdQnz-7eAgvuwl71-Ncg'
    });

    if (response.statusCode == 200) {
      return Profile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
