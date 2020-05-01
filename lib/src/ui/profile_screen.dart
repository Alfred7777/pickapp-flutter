import 'package:flutter/material.dart';
import '../blocs/profile_bloc.dart';
import '../models/profile_model.dart';

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
          return _buildProfileScreen(snapshot.data);
        }
        else if (snapshot.hasError){
          return Text(snapshot.error.toString());
        }
        return Center(child: CircularProgressIndicator());
      }
    );
  }
  Container _buildProfileScreen(Profile data) {
    return Container(
      padding: const EdgeInsets.all(17.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(12.0),
                child: Text(
                  data.name,
                  style: TextStyle(
                    fontSize: 30.0)
                  )
              )
            ]
          )
        ]
      )
    );
  }
}
