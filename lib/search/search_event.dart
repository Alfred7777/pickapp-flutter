import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchRequested extends SearchEvent {
  final String query;
  final String searchType;

  const SearchRequested({
    @required this.query,
    @required this.searchType,
  });

  @override
  List<Object> get props => [query, searchType];
}

class SearchTabChanged extends SearchEvent {
  final String query;
  final String searchType;

  const SearchTabChanged({
    @required this.query,
    @required this.searchType,
  });

  @override
  List<Object> get props => [query, searchType];
}
