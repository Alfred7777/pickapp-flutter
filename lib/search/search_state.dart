import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchUninitialized extends SearchState {
  const SearchUninitialized();

  @override
  List<Object> get props => [];
}

class SearchInProgress extends SearchState {
  final String query;
  final String searchType;

  const SearchInProgress({
    @required this.query,
    @required this.searchType,
  });

  @override
  List<Object> get props => [query, searchType];
}

class SearchCompleted extends SearchState {
  final String query;
  final String searchType;
  final List<dynamic> searchResult;

  const SearchCompleted({
    @required this.query,
    @required this.searchType,
    @required this.searchResult,
  });

  @override
  List<Object> get props => [query, searchType, searchResult];
}

class SearchFailure extends SearchState {
  final String error;

  const SearchFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
