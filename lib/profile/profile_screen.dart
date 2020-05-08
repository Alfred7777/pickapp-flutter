import 'package:flutter/material.dart';
import 'package:PickApp/profile/profile_bloc.dart';
import 'package:PickApp/profile/profile_model.dart';
import 'package:PickApp/widgets/top_bar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    profileBloc.fetchProfile();
    return StreamBuilder(
        stream: profileBloc.profile,
        builder: (context, AsyncSnapshot<Profile> snapshot) {
          if (snapshot.hasData) {
            return _buildProfileScreen(context, snapshot.data);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Center(child: CircularProgressIndicator());
        });
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
                border: Border.all(color: Colors.white, width: 10.0))));
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
        fontWeight: FontWeight.w200);

    return Text('@' + username, style: _usernameStyle);
  }

  Widget _buildBio(String bio) {
    var _bioStyle = TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.italic,
        color: Colors.blueGrey,
        fontSize: 22.0,
        fontWeight: FontWeight.w400);

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
              _buildUserName(data.unique_username.toString()),
              SizedBox(height: screenSize.height / 20.0),
              _buildBio(data.bio.toString())
            ],
          )))
        ],
      ),
    );
  }
}
