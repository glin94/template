import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:darulfikr/bloc/search_bloc/search_error.dart';
import 'package:darulfikr/bloc/search_bloc/search_event.dart';
import 'package:darulfikr/bloc/search_bloc/search_state.dart';
import 'package:darulfikr/resources/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository searchRepository;
  List<String> list = List();
  SearchBloc({this.searchRepository});

  @override
  Stream<SearchEvent> transform(Stream<SearchEvent> events) {
    return (events as Observable<SearchEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  void onTransition(Transition<SearchEvent, SearchState> transition) {
    print(transition);
  }

  @override
  SearchState get initialState {
    searchRepository.getPref().then((stringlist) => list = stringlist);
    return SearchStateEmpty(list);
  }

  @override
  Stream<SearchState> mapEventToState(
    SearchState currentState,
    SearchEvent event,
  ) async* {
    if (event is TextChanged) {
      final String searchTerm = event.text;
      if (searchTerm.isEmpty) {
        final list = await searchRepository.getPref();
        yield SearchStateEmpty(list);
      } else {
        yield SearchStateLoading();
        try {
          final results = await searchRepository.search(searchTerm);
          searchRepository.setPref(searchTerm);
          yield SearchStateSuccess(results);
        } catch (error) {
          yield error is SearchResultError
              ? SearchStateError(error.message)
              : SearchStateError('Что-то пошло не так ');
        }
      }
    }
  }

  Future setPref(String searchTerm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    list = (prefs.getStringList("searchList" ?? []));
    list.removeWhere((s) => s == searchTerm);
    list.add(searchTerm);
    prefs.setStringList('searchList', list);
  }
}
