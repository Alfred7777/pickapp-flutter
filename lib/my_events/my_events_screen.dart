import 'package:intl/intl.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:PickApp/event_details/event_details_screen.dart';
import 'my_events_bloc.dart';
import 'my_events_state.dart';
import 'my_events_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';

class MyEventsScreen extends StatefulWidget {
  MyEventsScreen();

  @override
  State<MyEventsScreen> createState() => MyEventsScreenState();
}

class MyEventsScreenState extends State<MyEventsScreen> {
  final eventRepository = EventRepository();
  MyEventsBloc _myEventsBloc;

  @override
  void initState() {
    super.initState();
    _myEventsBloc = MyEventsBloc(eventRepository: eventRepository);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyEventsBloc, MyEventsState>(
      bloc: _myEventsBloc,
      builder: (context, state) {
        if (state is MyEventsUninitialized) {
          _myEventsBloc.add(FetchMyEvents());
        }
        if (state is MyEventsReady) {
          return _buildMyEvents(state.myEvents);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildEventBar(Event event) {
    var screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        var route = MaterialPageRoute<void>(builder: (context) => EventDetailsScreen(eventID: event.id));
        Navigator.push(context, route);
      },
      child: Container(
        height: 0.09 * screenSize.height,
        width: screenSize.width,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black45, width: 0.3),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0.05 * screenSize.width),
              child: Container(
                height: 0.05 * screenSize.height,
                width: 0.05 * screenSize.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/event_icon/${event.disciplineID}.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 0.04 * screenSize.width),
                child: Text(
                  event.name,
                  style: TextStyle(
                    color: Color(0xFF3D3A3A), 
                    fontSize: 0.025 * screenSize.height, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              height: 0.09 * screenSize.height,
              width: 0.13 * screenSize.height,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.black45, width: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  DateFormat.jm().format(event.startDate),
                  style: TextStyle(
                    color: Color(0xFFA7A7A7), 
                    fontSize: 0.025 * screenSize.height, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDayList(DateTime date, List<Event> events) {
    var screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: 0.06 * screenSize.height,
          width: screenSize.width,
          decoration: BoxDecoration(
            color: Color(0xFFF3F3F3),
            border: Border(
              bottom: BorderSide(color: Colors.black45, width: 0.3),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 0.05 * screenSize.width),
                child: Text(
                  DateFormat.EEEE().add_MMMd().format(date),
                  style: TextStyle(
                    color: Color(0xFF3D3A3A), 
                    fontSize: 0.025 * screenSize.height, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildEventBar(events[index]);
          }
        ),
      ],
    );
  }

  Widget _buildMyEvents(Map <DateTime, List<Event>> myEvents) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: mainScreenTopBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 0.08 * screenSize.height,
                width: screenSize.width,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black45, width: 0.3),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 0.04 * screenSize.width,
                    top: 0.014 * screenSize.height,
                    bottom: 0.018 * screenSize.height,
                  ),
                  child: Text(
                    'My Events',
                    style: TextStyle(
                      color: Color(0xFF3D3A3A), 
                      fontSize: 0.04 * screenSize.height, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: myEvents.length,
                itemBuilder: (BuildContext context, int index) {
                  var date = myEvents.keys.elementAt(index);
                  return _buildEventDayList(date, myEvents[date]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}