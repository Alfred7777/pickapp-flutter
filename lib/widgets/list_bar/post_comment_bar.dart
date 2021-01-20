import 'package:flutter/material.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/widgets/profile_picture_rounded.dart';

class PostCommentBar extends StatelessWidget {
  final PostComment comment;

  const PostCommentBar({
    @required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 8,
            ),
            child: ProfilePicture(
              height: 44,
              width: 44,
              shape: BoxShape.circle,
              fit: BoxFit.fill,
              profilePictureUrl: comment.creator.profilePictureUrl,
            ),
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                minHeight: 50,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(
                  color: Colors.grey[300],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.creator.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      comment.content,
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
        ],
      ),
    );
  }
}
