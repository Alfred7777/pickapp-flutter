import 'package:rxdart/rxdart.dart';
import '../models/profile_model.dart';
import '../resources/repository.dart';

class ProfileBloc {
  final Repository _repository = Repository();

  final _profileFetcher = PublishSubject<Profile>();

  Stream<Profile> get profile => _profileFetcher.stream;

  fetchProfile() async {
    Profile profile = await _repository.fetchProfile();
    _profileFetcher.sink.add(profile);
  }

  dispose() {
    _profileFetcher.close();
  }
}

final profileBloc = ProfileBloc();
