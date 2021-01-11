import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/event_details/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventBar extends StatelessWidget {
  final Event event;

  const EventBar({
    @required this.event,
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
                builder: (context) => EventDetailsScreen(
                  eventID: event.id,
                ),
              );
              Navigator.push(context, route);
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
                          'assets/images/event_icon/${event.disciplineID}.png',
                        ),
                      ),
                    ),
                  ),
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
                            '${event.name}',
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
                  Column(
                    children: [
                      Text(
                        DateFormat.yMd().format(event.startDate),
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat.jm().format(event.startDate),
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    ],
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
