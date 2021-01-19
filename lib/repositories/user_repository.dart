import 'package:PickApp/client.dart';
import 'package:PickApp/utils/string_formatter.dart';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'event_repository.dart';
import 'package:http/http.dart' as http;

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

  Future<Map<String, dynamic>> getUserStats(String userID) async {
    final client = AuthenticatedApiClient();
    var url;
    if (userID != null) {
      url = 'user_dashboard/user_stats/$userID';
    } else {
      url = 'user_dashboard/user_stats';
    }

    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return {
        'event_participations': data['event_participations'],
        'events_organized': data['events_organized'],
        'last_events': data['last_events']
            .map<Event>((event) => Event.fromJson(event))
            .toList(),
      };
    } else {
      throw Exception('Failed to load profile2!');
    }
  }

  static Future<bool> isOnboardingCompleted() async {
    final client = AuthenticatedApiClient();
    var url = 'profile/onboarding/';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<ProfileDraft> getProfileDraft() async {
    final client = AuthenticatedApiClient();
    var url = 'profile/onboarding/draft';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return ProfileDraft.fromJson(json.decode(response.body));
    } else {
      throw Exception('Something went wrong. Please try again later.');
    }
  }

  static Future<User> createProfile(Map<String, String> params) async {
    final client = AuthenticatedApiClient();
    var url = 'profile';

    var response = await client.post(url, body: params);

    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        StringFormatter.formatErrors(json.decode(response.body)),
      );
    }
  }

  Future<String> updateProfile(String name, String bio) async {
    final client = AuthenticatedApiClient();
    var url = 'profile/edit';

    var body = {
      'name': '$name',
      'bio': '$bio',
    };

    body.removeWhere((key, value) {
      if (key == null || value == null || value == 'null') {
        return true;
      }
      return false;
    });

    var response = await client.post(url, body: body);

    if (response.statusCode == 201) {
      return 'Profile successfully updated.';
    } else {
      throw Exception('Failed to update profile!');
    }
  }

  Future<String> getProfilePictureUploadUrl() async {
    final client = AuthenticatedApiClient();
    var url = 'profile/upload_url';

    var response = await client.get(url);

    print(response.statusCode);

    if (response.statusCode == 200) {
      return json.decode(response.body)['url'];
    } else {
      throw Exception('Something went wrong. Please try again later.');
    }
  }

  Future<String> uploadNewProfilePicture(
      String uploadUrl, PickedFile image) async {
    var bytes = await image.readAsBytes();

    var response = await http.put(
      uploadUrl,
      body: bytes,
    );

    if (response.statusCode == 200) {
      return 'Profile photo uploaded succesfully.';
    } else if (response.statusCode == 413) {
      throw Exception('Photo is too large!');
    } else {
      throw Exception('Error uploading photo!');
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
