import 'package:PickApp/widgets/profile_picture_rounded.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_update_bloc.dart';
import 'profile_update_state.dart';
import 'profile_update_event.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/widgets/loading_screen.dart';

class ProfileUpdateScreen extends StatefulWidget {
  final String userID;

  ProfileUpdateScreen({@required this.userID});

  @override
  State<ProfileUpdateScreen> createState() => ProfileUpdateScreenState(
        userID: userID,
      );
}

class ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final String userID;
  final userRepository = UserRepository();
  ProfileUpdateBloc _profileUpdateBloc;

  TextEditingController _nameController;
  TextEditingController _bioController;

  ProfileUpdateScreenState({
    @required this.userID,
  });

  @override
  void initState() {
    super.initState();
    _profileUpdateBloc = ProfileUpdateBloc(
      userRepository: userRepository,
      userID: userID,
    );

    _nameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _profileUpdateBloc.close();
    super.dispose();
  }

  void _updateProfile() {
    _profileUpdateBloc.add(
      UpdateProfileButtonPressed(
        initialDetails: _profileUpdateBloc.state.props.first,
        name: _nameController.text,
        bio: _bioController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideScreenTopBar(
        title: 'Edit Profile',
      ),
      body: BlocListener<ProfileUpdateBloc, ProfileUpdateState>(
        bloc: _profileUpdateBloc,
        listener: (context, state) {
          if (state is ProfileUpdateFailure) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
                duration: Duration(milliseconds: 500),
              ),
            );
          }
          if (state is ProfileUpdateSuccess) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<ProfileUpdateBloc, ProfileUpdateState>(
          bloc: _profileUpdateBloc,
          builder: (context, state) {
            if (state is ProfileUpdateUninitialized) {
              _profileUpdateBloc.add(FetchInitialDetails(userID: userID));
            }
            if (state is ProfileUpdateReady) {
              return ProfileUpdateScrollable(
                initialDetails: state.initialDetails,
                nameController: _nameController,
                bioController: _bioController,
                updateProfile: _updateProfile,
              );
            }
            return LoadingScreen();
          },
        ),
      ),
    );
  }
}

class ProfileUpdateScrollable extends StatelessWidget {
  final User initialDetails;
  final TextEditingController nameController;
  final TextEditingController bioController;
  final Function updateProfile;

  final _formKey = GlobalKey<FormState>();

  ProfileUpdateScrollable({
    @required this.initialDetails,
    @required this.nameController,
    @required this.bioController,
    @required this.updateProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 18,
            ),
            child: ProfilePicture(
              width: 180,
              height: 180,
              profilePictureUrl: initialDetails.profilePictureUrl,
              border: Border.all(
                color: Colors.white,
                width: 10.0,
              ),
              fit: BoxFit.cover,
              shape: BoxShape.circle,
            ),
          ),
          NameAndBioForm(
            initName: initialDetails.name,
            initBio: initialDetails.bio,
            formKey: _formKey,
            nameController: nameController,
            bioController: bioController,
          ),
          UpdateButton(
            updateProfile: updateProfile,
          ),
        ],
      ),
    );
  }
}

class NameAndBioForm extends StatelessWidget {
  final String initName;
  final String initBio;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController bioController;

  const NameAndBioForm({
    @required this.initName,
    @required this.initBio,
    @required this.formKey,
    @required this.nameController,
    @required this.bioController,
  });

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    nameController.text = initName;
    bioController.text = initBio;
    return Form(
      key: formKey,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 32,
            ),
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 2.0,
                  ),
                ),
                errorStyle: TextStyle(color: Colors.red),
                labelText: 'Name',
              ),
              onEditingComplete: () => node.nextFocus(),
              validator: (value) {
                final nameSegmentRegex = RegExp(
                  r'^([A-ZĄĆĘŁŃÓŚŹŻ]{1}[a-ząćęłńóśźż]{1}[^ ]* ?)+$',
                );
                final nameCharactersRegex = RegExp(
                  r"^[A-ZĄĆĘŁŃÓŚŹŻa-ząćęłńóśźż '-]+$",
                );
                if (value.isEmpty) {
                  return 'Name is required!';
                }
                if (value.length > 40) {
                  return 'Name can\'t be longer than 40 characters!';
                }
                if (!nameSegmentRegex.hasMatch(value)) {
                  return 'Each name segment has to start with capital letter followed by at least one small letter.';
                }
                if (!nameCharactersRegex.hasMatch(value)) {
                  return 'Name can contain only letters, \' and -.';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32,
            ),
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: bioController,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 2.0,
                  ),
                ),
                errorStyle: TextStyle(color: Colors.red),
                labelText: 'Bio',
              ),
              onEditingComplete: () => node.nextFocus(),
              validator: (value) {
                if (value.length > 280) {
                  return 'Bio can\'t be longer than 280 characters!';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateButton extends StatelessWidget {
  final Function updateProfile;

  const UpdateButton({
    @required this.updateProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: MaterialButton(
        onPressed: updateProfile,
        height: 40,
        minWidth: 160,
        color: Colors.green,
        child: Text(
          'UPDATE PROFILE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
