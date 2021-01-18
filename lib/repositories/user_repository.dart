import 'package:PickApp/client.dart';
import 'package:PickApp/utils/string_formatter.dart';
import 'dart:convert';
import 'package:equatable/equatable.dart';

class UserRepository {
  Future<List<User>> searchUser(String searchPhrase) async {
    final client = AuthenticatedApiClient();
    final url = 'profile/search';
    var queryParams = {
      'phrase': searchPhrase,
    };

    var response = await client.get(url, queryParams: queryParams);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<User>((user) => User.fromJson(user))
          .toList();
    } else {
      throw Exception(
        'We can\'t show you search results right now. Please try again later.',
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
        profilePictureUrl: data['profile_picture_url'],
        userID: userID,
      );
    } else {
      throw Exception('Failed to load profile!');
    }
  }

  static Future<bool> isOnboardingCompleted() async {
    final client = AuthenticatedApiClient();
    var path = 'profile/onboarding/';

    var response = await client.get(path);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<ProfileDraft> getProfileDraft() async {
    final client = AuthenticatedApiClient();
    var path = 'profile/onboarding/draft';

    var response = await client.get(path);

    if (response.statusCode == 200) {
      return ProfileDraft.fromJson(json.decode(response.body));
    } else {
      throw Exception('Something went wrong. Please try again later');
    }
  }

  static Future<User> createProfile(Map<String, String> params) async {
    final client = AuthenticatedApiClient();
    var path = 'profile';

    var response = await client.post(path, body: params);

    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        StringFormatter.formatErrors(json.decode(response.body)),
      );
    }
  }
}

class User extends Equatable {
  final String bio;
  final String name;
  final String uniqueUsername;
  final String profilePicturePath;
  final String profilePictureUrl;
  final String userID;

  User({
    this.uniqueUsername,
    this.name,
    this.bio,
    this.userID,
    this.profilePicturePath,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      bio: json['bio'],
      name: json['name'],
      uniqueUsername: json['unique_username'],
      profilePicturePath: json['profile_picture_path'],
      profilePictureUrl: json['profile_picture_url'],
      userID: json['user_id'],
    );
  }

  @override
  List<Object> get props => [
        name,
        uniqueUsername,
        bio,
        userID,
        profilePicturePath,
        profilePictureUrl
      ];
}

class ProfileDraft extends Equatable {
  final String bio;
  final String name;
  final String uniqueUsername;
  final String profilePicturePath;
  final String profilePictureUrl;
  final String userID;

  ProfileDraft({
    this.uniqueUsername,
    this.name,
    this.bio,
    this.userID,
    this.profilePicturePath,
    this.profilePictureUrl,
  });

  factory ProfileDraft.fromJson(Map<String, dynamic> json) {
    return ProfileDraft(
      bio: json['bio'],
      name: json['name'],
      uniqueUsername: json['unique_username'],
      profilePicturePath: json['profile_picture_path'],
      profilePictureUrl: json['profile_picture_url'],
      userID: json['user_id'],
    );
  }

  @override
  List<Object> get props => [
        name,
        uniqueUsername,
        bio,
        userID,
        profilePicturePath,
        profilePictureUrl
      ];
}
