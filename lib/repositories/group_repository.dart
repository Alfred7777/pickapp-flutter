import 'dart:convert';
import 'package:PickApp/utils/string_formatter.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/client.dart';
import 'user_repository.dart';

class GroupRepository {
  Future<String> createGroup({
    @required String name,
    @required String description,
    @required String disciplineID,
  }) async {
    var client = AuthenticatedApiClient();
    var url = 'groups';

    var body = {
      'name': '$name',
      'description': '$description',
    };

    var response = await client.post(url, body: body);

    if (response.statusCode == 201) {
      return 'Group successfully created.';
    } else {
      return StringFormatter.formatErrors(json.decode(response.body));
    }
  }

  Future<List<Group>> getMyGroups() async {
    var client = AuthenticatedApiClient();
    var url = 'groups/my_groups';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Group>((group) => Group.fromJson(group))
          .toList();
    } else {
      throw Exception(
        'We can\'t show you your group list right now. Please try again later.',
      );
    }
  }

  Future<Group> getGroupDetails(String groupID) async {
    final client = AuthenticatedApiClient();
    final url = 'events/$groupID';
    var response = await client.get(url);

    if (response.statusCode == 200) {
      return Group.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'We can\'t show you this group right now. Please try again later.',
      );
    }
  }

  Future<List<GroupInvitation>> getGroupInvitations() async {
    final client = AuthenticatedApiClient();
    final userRepository = UserRepository();
    final url = 'groups/my_invitations';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      // ignore: omit_local_variable_types
      List<GroupInvitation> groupInvitations = [];
      for (var invitation in json.decode(response.body)) {
        var groupDetails = await getGroupDetails(invitation['group_id']);
        var inviter = await userRepository.getProfileDetails(
          invitation['inviter_id'],
        );
        groupInvitations.add(GroupInvitation(
          id: invitation['id'],
          inviteeID: invitation['invitee_id'],
          groupDetails: groupDetails,
          inviter: inviter,
        ));
      }
      return groupInvitations;
    } else {
      return [];
    }
  }

  void answerInvitation(GroupInvitation groupInvitation, String answer) async {
    final client = AuthenticatedApiClient();
    final url = 'my_invitations/${groupInvitation.id}/${answer}';

    var response = await client.post(url);

    if (response.statusCode != 201) {
      throw Exception('Answering invitation failed! Please try again later.');
    }
  }
}

class Group {
  final String id;
  final String name;
  final String description;

  const Group({
    @required this.id,
    @required this.name,
    @required this.description,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class GroupInvitation {
  final String id;
  final String inviteeID;
  final Group groupDetails;
  final User inviter;

  const GroupInvitation({
    @required this.id,
    @required this.inviteeID,
    @required this.groupDetails,
    @required this.inviter,
  });
}
