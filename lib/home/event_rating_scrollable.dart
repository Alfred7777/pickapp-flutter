import 'package:PickApp/home/event_rating_bloc.dart';
import 'package:PickApp/home/event_rating_event.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/widgets/list_bar/user_bar.dart';
import 'package:flutter/material.dart';

class EventRatingScrollable extends StatefulWidget {
  final List<User> participants;
  final Event event;
  final Map<User, bool> usersRating;
  final EventRatingBloc eventRatingBloc;

  EventRatingScrollable({
    @required this.event,
    @required this.participants,
    @required this.usersRating,
    @required this.eventRatingBloc,
  });

  @override
  State<EventRatingScrollable> createState() => EventRatingScrollableState(
        participants: participants,
        event: event,
        usersRating: usersRating,
        eventRatingBloc: eventRatingBloc,
      );
}

class EventRatingScrollableState extends State<EventRatingScrollable> {
  final List<User> participants;
  final Event event;
  final EventRatingBloc eventRatingBloc;
  final Map<User, bool> usersRating;

  EventRatingScrollableState({
    @required this.participants,
    @required this.event,
    @required this.usersRating,
    @required this.eventRatingBloc,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Stack(children: [
      ListView(
        children: [
          SizedBox(height: 20),
          Center(
            child: Text(
              'Rate event participants',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 0.03 * screenSize.height),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                ),
                Text(
                  event.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(thickness: 1.0),
          SizedBox(height: 10),
          ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: participants.length,
              itemBuilder: (BuildContext context, int index) {
                return UserBar(
                  user: participants[index],
                  actionList: [
                    MaterialButton(
                      onPressed: () => _thumbUp(participants[index]),
                      child: Icon(
                          _isThumbUpPressed(participants[index])
                              ? Icons.thumb_up_alt_rounded
                              : Icons.thumb_up_alt_outlined,
                          color: _isThumbUpPressed(participants[index])
                              ? Colors.green
                              : Colors.grey),
                    ),
                    MaterialButton(
                      onPressed: () => _thumbDown(participants[index]),
                      child: Icon(
                          _isThumbDownPressed(participants[index])
                              ? Icons.thumb_down_alt_rounded
                              : Icons.thumb_down_alt_outlined,
                          color: _isThumbDownPressed(participants[index])
                              ? Colors.red
                              : Colors.grey),
                    ),
                  ],
                );
              }),
          SizedBox(height: 100),
        ],
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          width: 250.0,
          child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(ratingButtonText(), style: TextStyle(fontSize: 24)),
            onPressed: submitRatings,
            color: Colors.green,
            textColor: Colors.white,
          ),
        ),
      ),
    ]);
  }

  void submitRatings() async {
    eventRatingBloc.add(SubmitUserRating(
      usersRating: usersRating,
      event: event,
    ));
  }

  String ratingButtonText() {
    if (usersRating.isEmpty) {
      return 'Skip';
    } else {
      return 'Rate (' +
          usersRating.entries.length.toString() +
          '/' +
          participants.length.toString() +
          ')';
    }
  }

  void _thumbUp(user) async {
    if (usersRating[user] == null) {
      setUserRating(user, true);
    } else if (usersRating[user] == false) {
      setUserRating(user, true);
    } else {
      setState(() => usersRating.remove(user));
    }
  }

  void setUserRating(user, value) {
    setState(() => usersRating[user] = value);
  }

  void _thumbDown(user) async {
    if (usersRating[user] == null) {
      setUserRating(user, false);
    } else if (usersRating[user] == true) {
      setUserRating(user, false);
    } else {
      setState(() => usersRating.remove(user));
    }
  }

  bool _isThumbUpPressed(user) {
    return usersRating[user] ?? false;
  }

  bool _isThumbDownPressed(user) {
    if (usersRating[user] == false) {
      return true;
    } else {
      return false;
    }
  }
}
