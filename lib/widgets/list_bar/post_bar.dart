import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:PickApp/group_details/post_details/post_details_screen.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/widgets/profile_picture_rounded.dart';

class PostBar extends StatelessWidget {
  final String groupID;
  final GroupPost post;
  final bool redirectToDetails;

  const PostBar({
    @required this.groupID,
    @required this.post,
    @required this.redirectToDetails,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: !redirectToDetails
          ? null
          : () {
              var route = MaterialPageRoute<void>(
                builder: (context) => PostDetailsScreen(
                  groupID: groupID,
                  groupPost: post,
                ),
              );
              Navigator.push(context, route);
            },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[100],
              width: 8,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 0.024 * screenSize.height,
            bottom: 0.014 * screenSize.height,
            left: 0.032 * screenSize.width,
            right: 0.032 * screenSize.width,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PostCreatorBar(
                creator: post.creator,
                //postDate: post.date,
              ),
              PostContent(
                content: post.content,
                numberOfAnswers: post.numberOfAnswers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostCreatorBar extends StatelessWidget {
  final User creator;
  //final DateTime postDate;

  const PostCreatorBar({
    @required this.creator,
    //@required this.postDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProfilePicture(
          height: 48,
          width: 48,
          shape: BoxShape.circle,
          fit: BoxFit.cover,
          profilePictureUrl: creator.profilePictureUrl,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${creator.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   [
                //     DateFormat.MMMMd().format(postDate),
                //     DateFormat.y().add_Hm().format(postDate),
                //   ].join(', '),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                //   style: TextStyle(
                //     color: Colors.grey[500],
                //     fontSize: 13,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PostContent extends StatelessWidget {
  final String content;
  final int numberOfAnswers;

  const PostContent({
    @required this.content,
    @required this.numberOfAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          thickness: 0.5,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 3,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            // child: Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              content,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
              ),
            ),
          ),
          // ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Text(
              'answers: ${numberOfAnswers}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
