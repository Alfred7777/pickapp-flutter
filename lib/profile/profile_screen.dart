import 'package:PickApp/profile/profile_event.dart';
import 'package:PickApp/profile/profile_state.dart';
import 'package:PickApp/profile/profile_bloc.dart';
import 'package:PickApp/repositories/userRepository.dart';
import 'package:flutter/material.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;

  ProfileScreen({this.userID});

  @override
  ProfileScreenState createState() => ProfileScreenState(userID: userID);
}

class ProfileScreenState extends State<ProfileScreen> {
  final String userID;
  final userRepository = UserRepository();
  ProfileBloc _profileBloc;

  ProfileScreenState({this.userID});

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
          return _buildProfileScreen(context, state.details);
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

  Widget _buildProfileCover(Size screenSize) {
    return Container(
      height: screenSize.height / 3.5,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'assets/images/event_placeholder/04aa25eb-5f6e-47fd-b6a8-92cf9ef0bee6.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 190,
        height: 190,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/profile_placeholder.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFullName(String full_name) {
    var _nameStyle = TextStyle(
      color: Colors.black,
      fontSize: 30.0,
      fontWeight: FontWeight.w600,
    );

    return Text(
      full_name,
      style: _nameStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUserName(String username) {
    var _usernameStyle = TextStyle(
      color: Colors.black,
      fontSize: 18.0,
      fontWeight: FontWeight.w200,
    );

    return Text('@' + username, style: _usernameStyle);
  }

  Widget _buildBio(String bio) {
    var _bioStyle = TextStyle(
      fontStyle: FontStyle.italic,
      color: Colors.blueGrey,
      fontSize: 22.0,
      fontWeight: FontWeight.w400,
    );

    return Center(
      child: Text(
        '"' + bio + '"',
        style: _bioStyle,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFollowButton(screenSize) {
    return ButtonTheme(
      height: 40,
      minWidth: 0.34 * screenSize.width,
      child: FlatButton(
        onPressed: () {},
        color: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text('FOLLOW',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Scaffold _buildProfileScreen(BuildContext context, User data) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: sideScreenTopBar(context),
      body: Stack(
        children: <Widget>[
          _buildProfileCover(screenSize),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: screenSize.height / 8.5),
                  _buildProfileImage(),
                  _buildFullName(data.name.toString()),
                  _buildUserName(data.uniqueUsername.toString()),
                  SizedBox(height: screenSize.height / 60.0),
                  _buildFollowButton(screenSize),
                  SizedBox(height: screenSize.height / 60.0),
                  _buildBio(data.bio.toString()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
