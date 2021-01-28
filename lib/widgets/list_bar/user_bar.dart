import 'package:PickApp/profile/profile_screen.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:flutter/material.dart';

import '../profile_picture_rounded.dart';

class UserBar extends StatelessWidget {
  final User user;
  final List<MaterialButton> actionList;

  const UserBar({
    @required this.user,
    @required this.actionList,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            onTap: () {
              var route = MaterialPageRoute<void>(
                builder: (context) => ProfileScreen(
                  userID: user.userID,
                ),
              );
              Navigator.push(context, route);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 6,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProfilePicture(
                    height: 52,
                    width: 52,
                    shape: BoxShape.circle,
                    fit: BoxFit.cover,
                    profilePictureUrl: user.profilePictureUrl,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.name}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF3D3A3A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${user.uniqueUsername}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFA7A7A7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ButtonBar(
                    mainAxisSize: MainAxisSize.min,
                    buttonPadding: EdgeInsets.zero,
                    children: actionList,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
