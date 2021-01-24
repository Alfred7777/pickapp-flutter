import 'package:PickApp/authentication/authentication_bloc.dart';
import 'package:PickApp/authentication/authentication_event.dart';
import 'package:PickApp/utils/choose_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'profile_bloc.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/profile_picture_rounded.dart';
import 'package:PickApp/widgets/list_bar/event_bar.dart';
import 'package:PickApp/profile_update/profile_update_screen.dart';

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

  ProfileScreenState({
    this.userID,
  });

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc(
      userRepository: userRepository,
      userID: userID,
    );
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  void _logout() async {
    BlocProvider.of<AuthenticationBloc>(context).add(
      LoggedOut(),
    );
  }

  void _updateProfilePicture() async {
    var _source = await ChooseImage.chooseImageSource();
    if (_source != null) {
      var _pickedPicture = await ChooseImage.chooseImage(_source);
      _profileBloc.add(UpdateProfilePicture(
        pictureUploadUrl: _profileBloc.state.props.last,
        pickedProfilePicture: _pickedPicture,
      ));
    }
  }

  Future<void> _editProfile() async {
    var route = MaterialPageRoute<void>(
      builder: (context) => ProfileUpdateScreen(
        userID: userID,
      ),
    );
    await Navigator.push(context, route);
    _profileBloc.add(FetchProfile(userID: userID));
  }

  Future<void> _refreshView() async {
    _profileBloc.add(FetchProfile(userID: userID));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: userID == null
          ? MainScreenTopBar(
              title: 'Profile',
            )
          : SideScreenTopBar(
              title: 'Profile',
            ),
      body: BlocListener<ProfileBloc, ProfileState>(
        bloc: _profileBloc,
        listener: (context, state) {
          if (state is ProfileFailure) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          bloc: _profileBloc,
          condition: (prevState, currState) {
            if (currState is ProfileLoading) {
              return false;
            }
            if (currState is ProfileFailure) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            if (state is ProfileUninitialized) {
              _profileBloc.add(FetchProfile(userID: userID));
            }
            if (state is ProfileReady) {
              return RefreshIndicator(
                onRefresh: _refreshView,
                child: ProfileScrollable(
                  profileDetails: state.details,
                  rating: state.rating,
                  userStats: state.stats,
                  isLoggedUser: userID == null,
                  editProfile: _editProfile,
                  updateProfilePicture: _updateProfilePicture,
                  logout: _logout,
                ),
              );
            }
            return LoadingScreen();
          },
        ),
      ),
    );
  }
}

class ProfileScrollable extends StatelessWidget {
  final User profileDetails;
  final Map<String, dynamic> userStats;
  final Map<dynamic, dynamic> rating;
  final bool isLoggedUser;
  final Function editProfile;
  final Function updateProfilePicture;
  final Function logout;

  const ProfileScrollable({
    @required this.profileDetails,
    @required this.userStats,
    @required this.rating,
    @required this.isLoggedUser,
    @required this.editProfile,
    @required this.updateProfilePicture,
    @required this.logout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfilePhoto(
                profilePictureUrl: profileDetails.profilePictureUrl,
                updateProfilePicture: updateProfilePicture,
                isLoggedUser: isLoggedUser,
              ),
              ProfileInfo(
                name: profileDetails.name,
                username: profileDetails.uniqueUsername,
              ),
              ProfileRating(
                thumbsUp: rating['thumbs_up'],
                thumbsDown: rating['thumbs_down'],
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Divider(
                  color: Colors.grey[400],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: 4,
                ),
                child: ProfileBio(
                  bio: profileDetails.bio,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Divider(
                  color: Colors.grey[400],
                ),
              ),
              ProfileStats(
                stats: userStats,
              ),
            ],
          ),
          isLoggedUser
              ? Positioned(
                  top: 2,
                  right: 4,
                  child: MaterialButton(
                    onPressed: logout,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    height: 56,
                    minWidth: 56,
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Icon(
                          Icons.exit_to_app,
                          color: Colors.grey[400],
                        ),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    shape: CircleBorder(),
                  ),
                )
              : Container(),
          isLoggedUser
              ? Positioned(
                  top: 2,
                  left: 4,
                  child: MaterialButton(
                    onPressed: editProfile,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    height: 56,
                    minWidth: 56,
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.grey[400],
                        ),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    shape: CircleBorder(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

class ProfilePhoto extends StatelessWidget {
  final String profilePictureUrl;
  final Function updateProfilePicture;
  final bool isLoggedUser;

  const ProfilePhoto({
    @required this.profilePictureUrl,
    @required this.updateProfilePicture,
    @required this.isLoggedUser,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        bottom: 8,
      ),
      child: Stack(
        children: [
          ProfilePicture(
            height: 180,
            width: 180,
            profilePictureUrl: profilePictureUrl,
            border: Border.all(
              color: Colors.grey[200],
              width: 8,
            ),
            fit: BoxFit.cover,
            shape: BoxShape.circle,
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: isLoggedUser
                ? MaterialButton(
                    onPressed: updateProfilePicture,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    height: 40,
                    minWidth: 40,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.grey[400],
                    ),
                    shape: CircleBorder(),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}

class ProfileRating extends StatelessWidget {
  final int thumbsUp;
  final int thumbsDown;

  const ProfileRating({
    @required this.thumbsUp,
    @required this.thumbsDown,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(height: 80.0),
        Rate(icon: Icons.thumb_up, count: thumbsUp, color: Colors.green),
        SizedBox(width: 30.0),
        Rate(icon: Icons.thumb_down, count: thumbsDown, color: Colors.red),
      ])
    ]);
  }
}

class Rate extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  Rate({
    @required this.icon,
    @required this.count,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: color),
      SizedBox(height: 1.0),
      Text(
        count.toString(),
        style: TextStyle(color: color),
      ),
    ]);
  }
}

class ProfileInfo extends StatelessWidget {
  final String name;
  final String username;

  const ProfileInfo({
    @required this.name,
    @required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '@$username',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ProfileBio extends StatelessWidget {
  final String bio;

  const ProfileBio({
    @required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: 0,
              left: 16,
            ),
            child: Text(
              'Bio',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 2,
            ),
            child: Text(
              bio ?? '',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ProfileStats({
    @required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'Organised events',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${stats['events_organized']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Event participations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${stats['event_participations']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Divider(
            color: Colors.grey[400],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 4,
          ),
          child: Text(
            'Last participations',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ProfileLastEvents(
          events: stats['last_events'],
        ),
      ],
    );
  }
}

class ProfileLastEvents extends StatelessWidget {
  final List<Event> events;

  const ProfileLastEvents({
    @required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        return EventBar(
          event: events[index],
          refreshView: null,
        );
      },
    );
  }
}
