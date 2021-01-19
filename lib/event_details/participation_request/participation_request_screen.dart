import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'participation_request_bloc.dart';
import 'participation_request_state.dart';
import 'participation_request_event.dart';
import 'package:PickApp/widgets/list_bar/user_bar.dart';
import 'package:PickApp/repositories/event_repository.dart';

class ParticipationRequestScreen extends StatefulWidget {
  final String eventID;

  ParticipationRequestScreen({@required this.eventID});

  @override
  State<ParticipationRequestScreen> createState() =>
      ParticipationRequestScreenState(eventID: eventID);
}

class ParticipationRequestScreenState
    extends State<ParticipationRequestScreen> {
  final String eventID;
  final eventRepository = EventRepository();
  ParticipationRequestBloc _participationRequestBloc;

  ParticipationRequestScreenState({@required this.eventID});

  @override
  void initState() {
    super.initState();
    _participationRequestBloc = ParticipationRequestBloc(
      eventRepository: eventRepository,
      eventID: eventID,
    );
  }

  @override
  void dispose() {
    _participationRequestBloc.close();
    super.dispose();
  }

  void _acceptParticipant(String userID) {
    _participationRequestBloc.add(
      AcceptParticipant(
        eventID: eventID,
        requesterID: userID,
      ),
    );
    _participationRequestBloc.add(FetchParticipationRequests(eventID: eventID));
  }

  void _rejectParticipant(String userID) {
    _participationRequestBloc.add(
      RejectParticipant(
        eventID: eventID,
        requesterID: userID,
      ),
    );
    _participationRequestBloc.add(FetchParticipationRequests(eventID: eventID));
  }

  Widget _buildFailureDialog(String errorMessage) {
    return AlertDialog(
      title: Text('An Error Occured!'),
      content: Text(errorMessage),
      actions: [
        FlatButton(
          child: Text('Try Again'),
          onPressed: () {
            Navigator.of(context).pop();
            _participationRequestBloc.add(
              FetchParticipationRequests(
                eventID: eventID,
              ),
            );
          },
        ),
        FlatButton(
          child: Text('Go Back'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideScreenTopBar(
        title: 'Participation Requests',
      ),
      body: SafeArea(
        child:
            BlocListener<ParticipationRequestBloc, ParticipationRequestState>(
          bloc: _participationRequestBloc,
          listener: (context, state) {
            if (state is AnswerParticipationRequestFailure) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                  duration: Duration(milliseconds: 500),
                ),
              );
            }
            if (state is FetchParticipationRequestsFailure) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _buildFailureDialog(state.error);
                },
              );
            }
          },
          child:
              BlocBuilder<ParticipationRequestBloc, ParticipationRequestState>(
            bloc: _participationRequestBloc,
            condition: (prevState, currState) {
              if (currState is AnswerParticipationRequestFailure) {
                return false;
              }
              if (currState is ParticipationRequestLoading) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state is ParticipationRequestUninitialized) {
                _participationRequestBloc.add(
                  FetchParticipationRequests(
                    eventID: eventID,
                  ),
                );
              }
              if (state is ParticipationRequestReady) {
                return ParticipationRequestList(
                  participationRequestList: state.participationRequestList,
                  acceptParticipant: _acceptParticipant,
                  rejectParticipant: _rejectParticipant,
                );
              }
              return LoadingScreen();
            },
          ),
        ),
      ),
    );
  }
}

class ParticipationRequestList extends StatelessWidget {
  final List<ParticipationRequest> participationRequestList;
  final Function acceptParticipant;
  final Function rejectParticipant;

  const ParticipationRequestList({
    @required this.participationRequestList,
    @required this.acceptParticipant,
    @required this.rejectParticipant,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    if (participationRequestList.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: participationRequestList.length,
        itemBuilder: (BuildContext context, int index) {
          return UserBar(
            user: participationRequestList[index].requester,
            actionList: [
              MaterialButton(
                onPressed: () => acceptParticipant(
                  participationRequestList[index].requester.userID,
                ),
                elevation: 0,
                height: 42,
                minWidth: 42,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.transparent,
                shape: CircleBorder(),
                child: Icon(
                  Icons.check,
                  size: 30,
                  color: Colors.green,
                ),
              ),
              MaterialButton(
                onPressed: () => rejectParticipant(
                  participationRequestList[index].requester.userID,
                ),
                elevation: 0,
                height: 42,
                minWidth: 42,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.transparent,
                shape: CircleBorder(),
                child: Icon(
                  Icons.clear,
                  size: 30,
                  color: Colors.red,
                ),
              ),
            ],
          );
        },
      );
    } else {
      return Container(
        width: screenSize.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 0.02 * screenSize.width,
                right: 0.02 * screenSize.width,
                top: 0.06 * screenSize.width,
                bottom: 0.05 * screenSize.width,
              ),
              child: Text(
                'You don\'t have any participation requests right now.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  }
}
