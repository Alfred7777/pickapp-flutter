import 'package:flutter/material.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/event_details/event_details_screen.dart';

class EventInvitationBar extends StatelessWidget {
  final EventInvitation eventInvitation;
  final List<MaterialButton> actionList;

  const EventInvitationBar({
    @required this.eventInvitation,
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
                builder: (context) => EventDetailsScreen(
                  eventID: eventInvitation.eventDetails.id,
                  showButtons: false,
                ),
              );
              Navigator.push(context, route);
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: 6,
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
                          'assets/images/icons/event/${eventInvitation.eventDetails.disciplineID}.png',
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
                            '${eventInvitation.eventDetails.name}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF3D3A3A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${eventInvitation.inviter.uniqueUsername} has invited you',
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
