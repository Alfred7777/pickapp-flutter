import 'package:flutter/material.dart';

class EventDetails extends StatelessWidget {
  final Map<String, dynamic> eventDetails;
  EventDetails({@required this.eventDetails});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: 0.12 * screenSize.height,
        bottom: 0.02 * screenSize.height,
        left: 0.01 * screenSize.height,
        right: 0.01 * screenSize.height,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        color: Color(0xFFF3F3F3),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0.025 * screenSize.height),
              child: Container(
                height: 0.2 * screenSize.height,
                width: 0.2 * 1.24 * screenSize.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.4,
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/basket_event_placeholder.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0.012 * screenSize.height),
              child: Text(
                eventDetails['name'],
                style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0.01 * screenSize.height),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 0.01 * screenSize.width),
                    child: Icon(
                      Icons.schedule,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 0.01 * screenSize.width),
                    child: Text(
                      'from:',
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),
                  Text(
                    eventDetails['start_date'].toString(),
                    style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0.01 * screenSize.height),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 0.01 * screenSize.width),
                    child: Icon(
                      Icons.schedule,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 0.01 * screenSize.width),
                    child: Text(
                      'to:',
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),
                  Text(
                    eventDetails['end_date'].toString(),
                    style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(0.006 * screenSize.height),
              child: Divider(
                color: Colors.black,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 0.06 * screenSize.width),
                child: Text(
                  'About',
                  style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 0.06 * screenSize.width, 
                  right: 0.06 * screenSize.width,
                  top: 0.005 * screenSize.height,
                ),
                child: Text(
                  eventDetails['description'],
                  style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}