import 'package:PickApp/repositories/group_repository.dart';
import 'package:flutter/material.dart';

class GroupBar extends StatelessWidget {
  final Group group;

  const GroupBar({
    @required this.group,
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
              // redirect to group screen will be added in the future
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 0.01 * screenSize.height,
                horizontal: 0.02 * screenSize.width,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 0.06 * screenSize.width,
                        right: 0.01 * screenSize.width,
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
                              fontSize: 0.05 * screenSize.width,
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
