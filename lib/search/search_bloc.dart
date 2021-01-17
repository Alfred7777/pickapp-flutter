import 'search_event.dart';
import 'search_state.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/repositories/location_repository.dart';
import 'package:PickApp/repositories/group_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final UserRepository userRepository;
  final EventRepository eventRepository;
  final LocationRepository locationRepository;
  final GroupRepository groupRepository;

  SearchBloc({
    @required this.userRepository,
    @required this.eventRepository,
    @required this.locationRepository,
    @required this.groupRepository,
  });

  @override
  SearchState get initialState => SearchUninitialized();

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is SearchRequested) {
      yield SearchInProgress(
        query: event.query,
        searchType: event.searchType,
      );
      try {
        List<dynamic> searchResult;
        if (event.searchType == 'users') {
          searchResult = await userRepository.searchUser(event.query);
        }
        if (event.searchType == 'events') {
          searchResult = await eventRepository.searchEvent(event.query);
        }
        if (event.searchType == 'locations') {
          searchResult = await locationRepository.searchLocation(event.query);
        }
        if (event.searchType == 'groups') {
          searchResult = await groupRepository.searchGroup(event.query);
        }
        yield SearchCompleted(
          query: event.query,
          searchType: event.searchType,
          searchResult: searchResult,
        );
      } catch (error) {
        yield SearchFailure(error: error.message);
        yield SearchCompleted(
          query: event.query,
          searchType: event.searchType,
          searchResult: [],
        );
      }
    }
    if (event is SearchTabChanged) {
      if (event.query.isNotEmpty) {
        yield SearchInProgress(
          query: event.query,
          searchType: event.searchType,
        );
        try {
          List<dynamic> searchResult;
          if (event.searchType == 'users') {
            searchResult = await userRepository.searchUser(event.query);
          }
          if (event.searchType == 'events') {
            searchResult = await eventRepository.searchEvent(event.query);
          }
          if (event.searchType == 'locations') {
            searchResult = await locationRepository.searchLocation(event.query);
          }
          if (event.searchType == 'groups') {
            searchResult = await groupRepository.searchGroup(event.query);
          }
          yield SearchCompleted(
            query: event.query,
            searchType: event.searchType,
            searchResult: searchResult,
          );
        } catch (error) {
          yield SearchFailure(error: error.message);
          yield SearchCompleted(
            query: event.query,
            searchType: event.searchType,
            searchResult: [],
          );
        }
      } else {
        yield SearchUninitialized();
      }
    }
  }
}
