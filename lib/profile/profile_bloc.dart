import 'package:rxdart/rxdart.dart';
import './profile_model.dart';
import '../repository/repository.dart';

class ProfileBloc {
  final Repository _repository = Repository();

  final _profileFetcher = PublishSubject<Profile>();

  Stream<Profile> get profile => _profileFetcher.stream;

  void fetchProfile() async {
    var profile = await _repository.fetchProfile();
    _profileFetcher.sink.add(profile);
  }

  void dispose() {
    _profileFetcher.close();
  }
}

final profileBloc = ProfileBloc();
