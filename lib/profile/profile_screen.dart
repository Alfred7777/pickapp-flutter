import 'package:PickApp/profile/profile_event.dart';
import 'package:PickApp/profile/profile_state.dart';
import 'package:PickApp/profile/profile_bloc.dart';
import 'package:PickApp/repositories/userRepository.dart';
import 'package:flutter/material.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final userRepository = UserRepository();
  ProfileBloc _profileBloc;

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
        var userId = 'de9ac1c2-37e8-4244-9bc5-a6026c0ab717';
        if (state is InitialProfileState) {
          _profileBloc.add(FetchProfile(userID: userId));
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
          borderRadius: BorderRadius.circular(70.0),
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
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 30.0,
      fontWeight: FontWeight.w600,
    );

    return Text(
      full_name,
      style: _nameStyle,
    );
  }

  Widget _buildUserName(String username) {
    var _usernameStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 18.0,
      fontWeight: FontWeight.w200,
    );

    return Text('@' + username, style: _usernameStyle);
  }

  Widget _buildBio(String bio) {
    var _bioStyle = TextStyle(
      fontFamily: 'Roboto',
      fontStyle: FontStyle.italic,
      color: Colors.blueGrey,
      fontSize: 22.0,
      fontWeight: FontWeight.w400,
    );

    return Text(
      '"' + bio + '"',
      style: _bioStyle,
    );
  }

  Scaffold _buildProfileScreen(BuildContext context, Profile data) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: topBar(context),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: screenSize.height / 10.5),
                  _buildProfileImage(),
                  _buildFullName(data.name.toString()),
                  _buildUserName(data.uniqueUsername.toString()),
                  SizedBox(height: screenSize.height / 20.0),
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
