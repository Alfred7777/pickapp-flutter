class Profile {
  String _bio;
  String _name;
  String _unique_username;

  Profile.fromJson(parsedJson) {
    _bio = parsedJson['bio'];
    _name = parsedJson['name'];
    _unique_username = parsedJson['unique_username'];
  }

  String get bio => _bio;
  String get name => _name;
  String get unique_username => _unique_username;
}
