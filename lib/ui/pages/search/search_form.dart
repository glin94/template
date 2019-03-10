import 'package:darulfikr/ui/fragments/article_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:darulfikr/bloc/search_bloc/search_bloc.dart';
import 'package:darulfikr/bloc/search_bloc/search_event.dart';
import 'package:darulfikr/bloc/search_bloc/search_state.dart';
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/resources/repository.dart';

class SearchForm extends StatefulWidget {
  final SearchRepository searchRepository;

  SearchForm({
    Key key,
    @required this.searchRepository,
  }) : super(key: key);

  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  SearchBloc _searchBloc;

  @override
  void initState() {
    _searchBloc = SearchBloc(
      searchRepository: widget.searchRepository,
    );

    super.initState();
  }

  @override
  void dispose() {
    _searchBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SearchBar(searchBloc: _searchBloc),
        _SearchBody(searchBloc: _searchBloc)
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  final SearchBloc searchBloc;

  _SearchBar({Key key, this.searchBloc}) : super(key: key);

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  SearchBloc get searchBloc => widget.searchBloc;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: StadiumBorder(
          side: BorderSide(width: 0.5, color: Theme.of(context).accentColor)),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: TextField(
          controller: _textController,
          autocorrect: false,
          onChanged: (text) {
            searchBloc.dispatch(
              TextChanged(text: text),
            );
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            suffixIcon: GestureDetector(
                child: Icon(Icons.clear), onTap: _onClearTapped),
            border: InputBorder.none,
            hintText: 'Поиск...',
          ),
        ),
      ),
    );
  }

  void _onClearTapped() async {
    _textController.text = '';
    searchBloc.dispatch(TextChanged(text: ''));
  }
}

class _SearchBody extends StatelessWidget {
  final SearchBloc searchBloc;

  _SearchBody({Key key, this.searchBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchEvent, SearchState>(
      bloc: searchBloc,
      builder: (BuildContext context, SearchState state) {
        if (state is SearchStateEmpty) {
          if (state.list.isEmpty)
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Чтобы начать поиск, введите ключевое слово"),
            );
          else
            return Expanded(
                child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: state.list
                        .map<Widget>((s) => ListTile(
                            title: Text(s),
                            trailing: Icon(Icons.arrow_right),
                            onTap: () =>
                                searchBloc.dispatch(TextChanged(text: s))))
                        .toList()));
        }

        if (state is SearchStateLoading) {
          return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
              ));
        }
        if (state is SearchStateError) {
          return Text(state.error);
        }
        if (state is SearchStateSuccess) {
          return state.items.isEmpty
              ? Padding(
                  child: Text('Статья не найдена'),
                  padding: EdgeInsets.all(8),
                )
              : Expanded(child: _SearchResults(items: state.items));
        }
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<Article> items;

  const _SearchResults({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return ArticleWidget(article: items[index]);
        },
      ),
    );
  }
}
