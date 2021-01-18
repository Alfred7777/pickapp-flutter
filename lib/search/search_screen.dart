import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_bloc.dart';
import 'search_state.dart';
import 'search_event.dart';
import 'package:PickApp/widgets/search/search_loading.dart';
import 'package:PickApp/widgets/search/search_placeholder.dart';
import 'package:PickApp/widgets/list_bar/user_bar.dart';
import 'package:PickApp/widgets/list_bar/event_bar.dart';
import 'package:PickApp/widgets/list_bar/location_bar.dart';
import 'package:PickApp/widgets/list_bar/group_bar.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/repositories/location_repository.dart';
import 'package:PickApp/repositories/group_repository.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen();

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final userRepository = UserRepository();
  final eventRepository = EventRepository();
  final locationRepository = LocationRepository();
  final groupRepository = GroupRepository();
  SearchBloc _searchBloc;

  TabController _tabController;
  String _searchType;
  TextEditingController _queryTextController;
  Timer _debounce;
  final int _debouncetime = 500;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    _searchBloc = SearchBloc(
      userRepository: userRepository,
      eventRepository: eventRepository,
      locationRepository: locationRepository,
      groupRepository: groupRepository,
    );

    _queryTextController = TextEditingController();
    _queryTextController.addListener(_onQueryChanged);

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    _searchType = 'users';
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _queryTextController.removeListener(_onQueryChanged);
    _queryTextController.dispose();
    _searchBloc.close();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        setState(() {
          _searchType = 'users';
        });
      }
      if (_tabController.index == 1) {
        setState(() {
          _searchType = 'events';
        });
      }
      if (_tabController.index == 2) {
        setState(() {
          _searchType = 'locations';
        });
      }
      if (_tabController.index == 3) {
        setState(() {
          _searchType = 'groups';
        });
      }
      _searchBloc.add(
        SearchTabChanged(
          query: _queryTextController.text,
          searchType: _searchType,
        ),
      );
    }
  }

  void _onQueryChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debouncetime), () {
      if (_queryTextController.text.isNotEmpty) {
        if (_searchBloc.state is SearchUninitialized) {
          _searchBloc.add(
            SearchRequested(
              query: _queryTextController.text,
              searchType: _searchType,
            ),
          );
        } else {
          if (_searchBloc.state.props.first != _queryTextController.text &&
              _searchBloc.state is! SearchInProgress) {
            _searchBloc.add(
              SearchRequested(
                query: _queryTextController.text,
                searchType: _searchType,
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: SearchTopBar(
        queryTextController: _queryTextController,
        searchFieldHint: 'Search for ${_searchType}',
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocListener<SearchBloc, SearchState>(
          bloc: _searchBloc,
          listener: (context, state) {
            if (state is SearchFailure) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                elevation: 1,
                child: Container(
                  height: 52,
                  width: screenSize.width,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.grey[700],
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: [
                      Tab(
                        text: 'Users',
                        icon: Icon(
                          Icons.person,
                        ),
                        iconMargin: EdgeInsets.zero,
                      ),
                      Tab(
                        text: 'Events',
                        icon: Icon(
                          Icons.event_note,
                        ),
                        iconMargin: EdgeInsets.zero,
                      ),
                      Tab(
                        text: 'Locations',
                        icon: Icon(
                          Icons.place,
                        ),
                        iconMargin: EdgeInsets.zero,
                      ),
                      Tab(
                        text: 'Groups',
                        icon: Icon(
                          Icons.group,
                        ),
                        iconMargin: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  bloc: _searchBloc,
                  condition: (prevState, currState) =>
                      currState is! SearchFailure,
                  builder: (context, state) {
                    if (state is SearchInProgress) {
                      return SearchLoading(query: state.query);
                    }
                    if (state is SearchCompleted) {
                      return SearchResults(
                        query: state.query,
                        searchType: state.searchType,
                        searchResult: state.searchResult,
                      );
                    }
                    return SearchPlaceholder();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResults extends StatelessWidget {
  final String query;
  final String searchType;
  final List<dynamic> searchResult;

  const SearchResults({
    @required this.query,
    @required this.searchType,
    @required this.searchResult,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    if (searchResult.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: searchResult.length,
        // ignore: missing_return
        itemBuilder: (BuildContext context, int index) {
          if (searchType == 'users') {
            return UserBar(
              user: searchResult[index],
              actionList: [],
            );
          }
          if (searchType == 'events') {
            return EventBar(
              event: searchResult[index],
              refreshView: () {},
            );
          }
          if (searchType == 'locations') {
            return LocationBar(
              location: searchResult[index],
            );
          }
          if (searchType == 'groups') {
            return GroupBar(
              group: searchResult[index],
            );
          }
        },
      );
    } else {
      return Container(
        width: screenSize.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 0.02 * screenSize.width,
                right: 0.02 * screenSize.width,
                top: 0.06 * screenSize.width,
                bottom: 0.05 * screenSize.width,
              ),
              child: Text(
                'No results found for: \"$query\"',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  }
}
