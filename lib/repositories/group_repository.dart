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

  Future<String> deleteGroup(String groupID) async {
    final client = AuthenticatedApiClient();
    final url = 'groups/$groupID/delete';

    var response = await client.delete(url);

    if (response.statusCode == 201) {
      return 'Successfully deleted group.';
    } else {
      throw Exception(
        'Deleting this group failed! Please try again later.',
      );
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
    final url = 'groups/$groupID';
    var response = await client.get(url);

    if (response.statusCode == 200) {
      return Group.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'We can\'t show you this group right now. Please try again later.',
      );
    }
  }

  Future<List<GroupPost>> getGroupPosts(String groupID) async {
    var _userRepository = UserRepository();
    final client = AuthenticatedApiClient();
    final url = 'groups/$groupID/posts';

    var response = await client.get(url);

    if (response.statusCode == 201) {
      // ignore: omit_local_variable_types
      List<GroupPost> groupPosts = [];
      for (var post in json.decode(response.body)) {
        var _creator = await _userRepository.getProfileDetails(
          post['user_id'],
        );
        groupPosts.add(GroupPost(
          id: post['id'],
          content: post['post_body'],
          numberOfAnswers: post['comment_count'],
          creator: _creator,
        ));
      }
      return groupPosts;
    } else {
      throw Exception(
        'We can\'t show you this group posts right now. Please try again later.',
      );
    }
  }

  Future<List<PostComment>> getPostComments(
      String groupID, String postID) async {
    var _userRepository = UserRepository();
    final client = AuthenticatedApiClient();
    final url = 'groups/$groupID/$postID/comments';

    var response = await client.get(url);

    if (response.statusCode == 201) {
      // ignore: omit_local_variable_types
      List<PostComment> postAnswers = [];
      for (var answer in json.decode(response.body)) {
        var _creator = await _userRepository.getProfileDetails(
          answer['user_id'],
        );
        postAnswers.add(PostComment(
          id: answer['id'],
          postID: answer['post_id'],
          content: answer['comment_body'],
          creator: _creator,
        ));
      }
      return postAnswers;
    } else {
      throw Exception(
        'We can\'t show you this group posts right now. Please try again later.',
      );
    }
  }

  Future<String> addGroupPost(
    String groupID,
    String content,
  ) async {
    final client = AuthenticatedApiClient();
    final url = 'groups/$groupID/add_post';

    var body = {
      'post_body': '$content',
    };

    var response = await client.post(url, body: body);

    if (response.statusCode == 201) {
      return 'Post successfully added.';
    } else {
      throw Exception(
        'Adding group post failed! Please try again later.',
      );
    }
  }

  Future<String> addPostAnswer(
    String groupID,
    String postID,
    String content,
  ) async {
    final client = AuthenticatedApiClient();
    final url = 'groups/$groupID/$postID/add_comment';

    var body = {
      'comment_body': '$content',
    };

    var response = await client.post(url, body: body);

    if (response.statusCode == 201) {
      return 'Post answer successfully added.';
    } else {
      throw Exception(
        'Adding post answer failed! Please try again later.',
      );
    }
  }

  Future<List<User>> getGroupMembers(String groupID) async {
    final client = AuthenticatedApiClient();
    final url = 'groups/$groupID/members';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<User>((member) => User.fromJson(member))
          .toList();
    } else {
      throw Exception(
        'We can\'t show you group members right now. Please try again later.',
      );
    }
  }

  void removeUser(String groupID, String userID) async {
    // to be implemented when backend is ready
  }

  Future<String> inviteToGroup(String groupID, String inviteeID) async {
    final client = AuthenticatedApiClient();
    final url = 'groups/$groupID/invite';

    var body = {
      'invitee_id': '$inviteeID',
    };

    var response = await client.post(url, body: body);

    if (response.statusCode == 201) {
      return 'Successfully invited user to group.';
    } else {
      throw Exception(json.decode(response.body)['message']);
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
    final url = 'groups/my_invitations/${groupInvitation.id}/${answer}';

    var response = await client.post(url);

    if (response.statusCode != 201) {
      throw Exception('Answering invitation failed! Please try again later.');
    }
  }

  Future<List<Group>> searchGroup(String searchPhrase) async {
    final client = AuthenticatedApiClient();
    final url = 'groups/search';
    var queryParams = {
      'phrase': searchPhrase,
    };

    var response = await client.get(url, queryParams: queryParams);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Group>((group) => Group.fromJson(group))
          .toList();
    } else {
      throw Exception(
        'We can\'t show you search results right now. Please try again later.',
      );
    }
  }
}

class Group {
  final String id;
  final String name;
  final String description;
  final String ownerID;
  final bool isOwner;

  const Group({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.ownerID,
    @required this.isOwner,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerID: json['owner_id'],
      isOwner: true, // change when data is returned
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

class GroupPost {
  final String id;
  final String content;
  final int numberOfAnswers;
  //final DateTime date;
  final User creator;

  const GroupPost({
    @required this.id,
    @required this.content,
    @required this.numberOfAnswers,
    //@required this.date,
    @required this.creator,
  });
}

class PostComment {
  final String id;
  final String postID;
  final String content;
  //final DateTime date;
  final User creator;

  const PostComment({
    @required this.id,
    @required this.postID,
    @required this.content,
    //@required this.date,
    @required this.creator,
  });
}
