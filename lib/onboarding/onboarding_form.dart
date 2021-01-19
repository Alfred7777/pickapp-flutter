import 'package:PickApp/onboarding/onboarding_bloc.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/widgets/profile_picture_rounded.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_event.dart';

class OnboardingForm extends StatefulWidget {
  final ProfileDraft profileDraft;

  OnboardingForm({@required this.profileDraft});

  @override
  State<OnboardingForm> createState() =>
      _OnboardingFormState(profileDraft: profileDraft);
}

class _OnboardingFormState extends State<OnboardingForm> {
  final _formKey = GlobalKey<FormState>();
  final ProfileDraft profileDraft;

  String profilePicturePath;

  TextEditingController nameController;
  TextEditingController uniqueUsernameController;
  TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: profileDraft.name);
    uniqueUsernameController = TextEditingController(
      text: profileDraft.uniqueUsername,
    );
    bioController = TextEditingController(text: profileDraft.bio);
    profilePicturePath = profileDraft.profilePicturePath;
  }

  @override
  void dispose() {
    nameController.dispose();
    uniqueUsernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  _OnboardingFormState({@required this.profileDraft});

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    var screenSize = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
        child: ListView(children: [
          Text(
            'Set up your profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32.0,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.01 * screenSize.height),
          Center(
            child: ProfilePicture(
              width: 160,
              height: 160,
              profilePictureUrl: profileDraft.profilePictureUrl,
              border: Border.all(
                color: Colors.white,
                width: 10.0,
              ),
              fit: BoxFit.cover,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 0.03 * screenSize.height),
          TextForm(
            label: 'Name',
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            maxLines: 1,
            validator: validateName,
            node: node,
          ),
          SizedBox(height: 0.03 * screenSize.height),
          TextForm(
            label: 'Username',
            controller: uniqueUsernameController,
            textCapitalization: TextCapitalization.none,
            keyboardType: TextInputType.name,
            maxLines: 1,
            validator: validateUniqueUsername,
            node: node,
          ),
          SizedBox(height: 0.03 * screenSize.height),
          TextForm(
            label: 'Bio',
            controller: bioController,
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            minLines: 5,
            validator: validateBio,
            node: node,
          ),
          SizedBox(height: 30.0),
          Center(
            child: ButtonTheme(
              minWidth: 0.9 * screenSize.width,
              height: 0.06 * screenSize.height,
              child: RaisedButton(
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: submitForm,
                color: Colors.green,
                elevation: 2.0,
                autofocus: false,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void submitForm() {
    if (_formKey.currentState.validate()) {
      BlocProvider.of<OnboardingBloc>(context).add(
        SubmitForm(
          name: nameController.text,
          uniqueUsername: uniqueUsernameController.text,
          bio: bioController.text,
          profilePicturePath: profilePicturePath,
          draft: ProfileDraft(
            bio: bioController.text,
            name: nameController.text,
            uniqueUsername: uniqueUsernameController.text,
          ),
        ),
      );
    }
  }

  String validateName(String name) {
    final nameSegmentRegex =
        RegExp(r'^([A-ZĄĆĘŁŃÓŚŹŻ]{1}[a-ząćęłńóśźż]{1}[^ ]* ?)+$');
    final nameCharactersRegex = RegExp(r"^[A-ZĄĆĘŁŃÓŚŹŻa-ząćęłńóśźż '-]+$");

    if (name.isEmpty) {
      return 'Name is required!';
    }
    if (name.length > 40) {
      return 'Name can\'t be longer than 40 characters!';
    }
    if (!nameSegmentRegex.hasMatch(name)) {
      return 'Each name segment has to start with capital letter followed by at least one small letter.';
    }
    if (!nameCharactersRegex.hasMatch(name)) {
      return "Name can contain only letters, ' and -.";
    }
    return null;
  }

  String validateUniqueUsername(String uniqueUsername) {
    final uniqueUsernameRegex = RegExp(r'^[.A-Za-z0-9_-]+$');

    if (uniqueUsername.isEmpty) {
      return 'Username is required!';
    }
    if (uniqueUsername.length > 32) {
      return 'Username can\'t be longer than 32 characters!';
    }
    if (!uniqueUsernameRegex.hasMatch(uniqueUsername)) {
      return 'Unique username can contain only letters, digits, -, . and _.';
    }
    return null;
  }

  String validateBio(String bio) {
    if (bio.length > 280) {
      return 'Bio can\'t be longer than 280 characters!';
    }
    return null;
  }
}

class TextForm extends StatelessWidget {
  final String label;
  final FocusScopeNode node;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int minLines;
  final String Function(String) validator;

  TextForm({
    this.label,
    this.node,
    this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLines,
    this.minLines,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.always,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
        errorMaxLines: 2,
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
      ),
      onEditingComplete: () => node.nextFocus(),
      validator: validator,
    );
  }
}
