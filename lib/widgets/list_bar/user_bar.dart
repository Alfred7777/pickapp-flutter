import 'package:PickApp/profile/profile_screen.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class UserBar extends StatelessWidget {
  final User user;
  final List<MaterialButton> actionList;

  const UserBar({
    @required this.user,
    @required this.actionList,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0.03 * screenSize.width,
        vertical: 0.006 * screenSize.height,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
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
                vertical: 0.01 * screenSize.height,
                horizontal: 0.02 * screenSize.width,
              ),
              child: Container(
                width: 0.96 * screenSize.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 0.084 * screenSize.height,
                      width: 0.084 * screenSize.height,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                            'assets/images/profile_placeholder.png',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 0.04 * screenSize.width),
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
                                fontSize: 0.05 * screenSize.width,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '@${user.uniqueUsername}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFFA7A7A7),
                                fontSize: 0.034 * screenSize.width,
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
      ),
    );
  }
}
