import 'package:PickApp/repositories/mapRepository.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:PickApp/repositories/userRepository.dart';
import 'package:mockito/mockito.dart';

class MockMapRepository extends Mock implements MapRepository {}

class MockEventRepository extends Mock implements EventRepository {}

class MockUserRepository extends Mock implements UserRepository {}
