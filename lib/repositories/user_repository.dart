import 'package:PickApp/client.dart';
import 'dart:convert';
import 'package:equatable/equatable.dart';

class UserRepository {
  Future<List<User>> searchUser(String searchPhrase) async {
    final client = AuthenticatedApiClient();
    final url = 'profile/search?phrase=${searchPhrase}';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<User>((user) => User.fromJson(user))
          .toList();
    } else {
      throw Exception(
        'We cannot show you search results right now. Please try again later.',
      );
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
}

class User extends Equatable {
  final String bio;
  final String name;
  final String uniqueUsername;
  final String userID;

  User({this.uniqueUsername, this.name, this.bio, this.userID});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      bio: json['bio'],
      name: json['name'],
      uniqueUsername: json['unique_username'],
      userID: json['user_id'],
    );
  }

  @override
  List<Object> get props => [name, uniqueUsername, bio];
}
