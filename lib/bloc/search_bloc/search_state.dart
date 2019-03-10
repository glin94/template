import 'package:equatable/equatable.dart';
import 'package:darulfikr/model/article.dart';

abstract class SearchState extends Equatable {
  SearchState([List props = const []]) : super(props);
}

class SearchStateEmpty extends SearchState {
  final List<String> list;

  SearchStateEmpty(this.list) : super([list]);

  @override
  String toString() => 'SearchStateEmpty';
}

class SearchStateLoading extends SearchState {
  @override
  String toString() => 'SearchStateLoading';
}

class SearchStateSuccess extends SearchState {
  final List<Article> items;

  SearchStateSuccess(this.items) : super([items]);

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}

class SearchStateError extends SearchState {
  final String error;

  SearchStateError(this.error) : super([error]);

  @override
  String toString() => 'SearchStateError';
}
