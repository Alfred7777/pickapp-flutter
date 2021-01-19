import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:PickApp/client.dart';

class NotificationRepository {
  Future<Map<String, dynamic>> getNotifications(
      String nextToken, int limit) async {
    var client = AuthenticatedApiClient();
    var queryParams;

    if (nextToken == null) {
      queryParams = {
        'limit': '$limit',
      };
    } else {
      queryParams = {
        'limit': '$limit',
        'next_token': '$nextToken',
      };
    }

    var response = await client.get(
      'my_notifications',
      queryParams: queryParams,
    );

    if (response.statusCode == 200) {
      var notifications = json.decode(response.body);
      return {
        'next_token': notifications['next_token'],
        'notifications': notifications['notifications']
            .map<Notification>((json) => Notification.fromJson(json))
            .toList(),
      };
    } else {
      throw Exception(
        'We can\'t show your notifications right now. Please try again later',
      );
    }
  }
}

class Notification {
  final String title;
  final String description;
  final String id;
  final String userID;
  final bool isUnread;

  const Notification({
    @required this.title,
    @required this.description,
    @required this.id,
    @required this.userID,
    @required this.isUnread,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      title: json['title'],
      description: json['description'],
      id: json['id'],
      userID: json['user_id'],
      isUnread: json['unread'],
    );
  }
}
