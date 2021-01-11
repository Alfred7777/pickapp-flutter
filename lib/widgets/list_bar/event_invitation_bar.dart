import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/widgets/sliver_map_header.dart';

class EventInvitationBar extends StatelessWidget {
  final EventInvitation eventInvitation;
  final Function answerInvitation;

  const EventInvitationBar({
    @required this.eventInvitation,
    @required this.answerInvitation,
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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return InvitationDialog(
                    eventInvitation: eventInvitation,
                    answerInvitation: answerInvitation,
                  );
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 0.01 * screenSize.height,
                horizontal: 0.02 * screenSize.width,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 0.12 * screenSize.width,
                    width: 0.12 * screenSize.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage(
                          'assets/images/event_icon/${eventInvitation.eventDetails.disciplineID}.png',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 0.04 * screenSize.width,
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
                              fontSize: 0.05 * screenSize.width,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${eventInvitation.inviter.uniqueUsername} has invited you',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InvitationDialog extends StatelessWidget {
  final EventInvitation eventInvitation;
  final Function answerInvitation;

  const InvitationDialog({
    @required this.eventInvitation,
    @required this.answerInvitation,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: 0.21 * screenSize.height,
        bottom: 0.055 * screenSize.height,
        left: 0.05 * screenSize.width,
        right: 0.05 * screenSize.width,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0.02 * screenSize.width),
        child: Material(
          color: Colors.grey[100],
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverMapHeader(
                      minExtent: 0.14 * screenSize.height,
                      maxExtent: 0.30 * screenSize.height,
                      markerPos: eventInvitation.eventDetails.position,
                      privacyBadge: null,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        InvitationDetails(eventInvitation: eventInvitation),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: 76,
                  width: 0.9 * screenSize.width,
                  color: Colors.black.withOpacity(0.6),
                  child: ButtonBar(
                    mainAxisSize: MainAxisSize.min,
                    alignment: MainAxisAlignment.spaceEvenly,
                    buttonPadding: EdgeInsets.zero,
                    children: [
                      InvitationButton(
                        eventInvitation: eventInvitation,
                        text: 'Accept',
                        color: Colors.green,
                        notifyParent: answerInvitation,
                      ),
                      InvitationButton(
                        eventInvitation: eventInvitation,
                        text: 'Reject',
                        color: Colors.red,
                        notifyParent: answerInvitation,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InvitationDetails extends StatelessWidget {
  final EventInvitation eventInvitation;

  const InvitationDetails({
    @required this.eventInvitation,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 0.012 * screenSize.height,
          ),
          child: Text(
            eventInvitation.eventDetails.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[850],
              fontSize: 0.072 * screenSize.width,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: 0.016 * screenSize.height,
              left: 0.05 * screenSize.width,
              right: 0.03 * screenSize.width,
            ),
            child: Text(
              'Start date',
              style: TextStyle(
                color: Color(0xFF3D3A3A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 0.03 * screenSize.width,
          ),
          child: Divider(
            color: Colors.grey[500],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: 0.05 * screenSize.width,
              right: 0.03 * screenSize.width,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 0.01 * screenSize.width),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
                Text(
                  DateFormat.Hm()
                          .add_EEEE()
                          .format(eventInvitation.eventDetails.startDate) +
                      ', ' +
                      DateFormat.MMMMd()
                          .format(eventInvitation.eventDetails.startDate) +
                      ', ' +
                      DateFormat.y()
                          .format(eventInvitation.eventDetails.startDate),
                  style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: 0.02 * screenSize.height,
              left: 0.05 * screenSize.width,
              right: 0.03 * screenSize.width,
            ),
            child: Text(
              'About',
              style: TextStyle(
                color: Color(0xFF3D3A3A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 0.03 * screenSize.width,
          ),
          child: Divider(
            color: Colors.grey[500],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: 0.05 * screenSize.width,
              right: 0.03 * screenSize.width,
            ),
            child: Text(
              eventInvitation.eventDetails.description,
              style: TextStyle(
                color: Color(0xFF3D3A3A),
                fontSize: 15,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 0.14 * screenSize.height,
        ),
      ],
    );
  }
}

class InvitationButton extends StatelessWidget {
  final EventInvitation eventInvitation;
  final String text;
  final Color color;
  final Function notifyParent;

  const InvitationButton({
    @required this.eventInvitation,
    @required this.text,
    @required this.color,
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return MaterialButton(
      height: 40,
      minWidth: 0.24 * screenSize.width,
      onPressed: () => notifyParent(eventInvitation, text),
      color: color,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 0.024 * screenSize.height,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          0.02 * screenSize.width,
        ),
      ),
    );
  }
}
