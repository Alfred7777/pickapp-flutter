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
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Scaffold _buildProfileScreen(Profile data) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
            child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: 170,
                          height: 170,
                          child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://a.espncdn.com/i/headshots/nba/players/full/6475.png'))),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0, bottom: 5.0),
                    child: Text(data.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30.0)),
                  ),
                  Text('@' + data.unique_username),
                  Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Center(
                          child: Container(
                        margin: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                            color: Colors.blueGrey[100],
                            border: Border.all(
                                width: 15.0, color: Colors.blueGrey[100]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        child: Text(data.bio,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                            )),
                      ))),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, left: 17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Comments',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      minLines: 1,
                      maxLines: 7,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'Write a comment',
                        filled: true,
                        fillColor: Colors.grey[10],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {//send comment to backend
                          }
                        )
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        )));
  }
}
