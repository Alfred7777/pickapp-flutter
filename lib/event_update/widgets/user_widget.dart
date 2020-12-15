import 'package:PickApp/profile/profile_event.dart';
import 'package:PickApp/profile/profile_state.dart';
import 'package:PickApp/profile/profile_bloc.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserWidget extends StatefulWidget {
  final String userID;

  UserWidget({this.userID});

  @override
  UserWidgetState createState() => UserWidgetState(userID: userID);
}

class UserWidgetState extends State<UserWidget> {
  final String userID;
  final userRepository = UserRepository();
  ProfileBloc _profileBloc;

  UserWidgetState({this.userID});

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc(userRepository: userRepository);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: _profileBloc,
      builder: (context, state) {
        if (state is InitialProfileState) {
          _profileBloc.add(FetchProfile(userID: userID));
        }
        if (state is ProfileLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ProfileLoaded) {
          return _buildUserWidget(context, state.details);
        }
        if (state is ProfileError) {
          return Center(
            child: Text('Error :('),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildUserWidget(BuildContext context, User data) {
    var screenSize = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(
        left: 0.04 * screenSize.width,
        right: 0.04 * screenSize.width,
        top: 0.014 * screenSize.height,
        bottom: 0.018 * screenSize.height,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/images/profile_placeholder.png'),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 14.0),
                child: Text(
                  data.name,
                  style: TextStyle(
                    color: Color(0xFF3D3A3A),
                    fontSize: 22,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 14.0),
                child: Text(
                  '@${data.uniqueUsername}',
                  style: TextStyle(
                    color: Color(0xFF3D3A3A),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
