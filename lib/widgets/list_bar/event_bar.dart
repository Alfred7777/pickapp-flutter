import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/event_details/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventBar extends StatelessWidget {
  final Event event;
  final Function refreshView;

  const EventBar({
    @required this.event,
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
                builder: (context) => EventDetailsScreen(
                  eventID: event.id,
                  showButtons: event.endDate.isAfter(DateTime.now()),
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
                          'assets/images/icons/event/${event.disciplineID}.png',
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
                            '${event.name}',
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
