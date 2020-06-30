import 'package:PickApp/client.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:PickApp/main.dart';
import 'package:equatable/equatable.dart';

class UserRepository {
  Future<String> authenticate({
    @required String email,
    @required String password,
  }) async {
    final url = 'http://150.254.78.200/api/login';
    var headers = {'Content-type': 'application/json'};
    var json = '{"email": "$email", "password": "$password"}';

    var response = await post(url, headers: headers, body: json);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception();
    }
  }

  Future<User> getProfileDetails(String userID) async {
    final client = AuthenticatedApiClient();
    var url;
    if (userID != null) {
      url = 'profile/$userID';
    } else {
      url = 'profile';
    }
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return User(
        name: data['name'],
        uniqueUsername: data['unique_username'],
        bio: data['bio'],
        userID: userID,
      );
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<String> getAuthToken() async {
    final authToken = await storage.read(key: 'jwt');
    if (authToken == null) return '';
    return authToken;
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'jwt');
    return;
  }

  Future<void> persistToken(String token) async {
    var authToken = (json.decode(token))['auth_token'];
    if (authToken != null) {
      await storage.write(key: 'jwt', value: authToken);
    }
    return;
  }

  Future<bool> hasToken() async {
    final key = await storage.read(key: 'jwt');
    if (key == null) return false;
    return true;
  }
}

class User extends Equatable {
  final String bio;
  final String name;
  final String uniqueUsername;
  final String userID;

  User({this.uniqueUsername, this.name, this.bio, this.userID});

  @override
  List<Object> get props => [name, uniqueUsername, bio,];
}
