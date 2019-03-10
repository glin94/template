import 'package:darulfikr/ui/pages/search/search_form.dart';
import 'package:flutter/material.dart';
import 'package:darulfikr/bloc/search_bloc/search_cache.dart';
import 'package:darulfikr/resources/repository.dart';

class Search extends StatefulWidget {
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  SearchRepository _searchRepository;

  @override
  void initState() {
    _searchRepository = SearchRepository(
      SearchCache(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Поиск статей')),
      body: SearchForm(
        searchRepository: _searchRepository,
      ),
    );
  }
}
