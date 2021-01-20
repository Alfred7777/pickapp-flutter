import 'package:flutter/material.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/group_details/group_details_screen.dart';

class GroupBar extends StatelessWidget {
  final Group group;
  final Function refreshView;

  const GroupBar({
    @required this.group,
    @required this.refreshView,
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
            onTap: () async {
              var route = MaterialPageRoute<void>(
                builder: (context) => GroupDetailsScreen(
                  groupID: group.id,
                ),
              );
              await Navigator.push(context, route);
              refreshView();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 6,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage(
                          'assets/images/icons/group/group_icon.png',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 14,
                        right: 4,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${group.name}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
