import 'package:flutter/material.dart';
import 'package:mapa_app/models/search_result.dart';

class SearchDestination extends SearchDelegate<SearchResult> {
  @override
  final String searchFieldLabel;

  SearchDestination() : this.searchFieldLabel = 'Buscar...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () => this.query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => this.close(context, SearchResult(cancelo: true)));
  }

  @override
  Widget buildResults(BuildContext context) {
    //Resultados de busqueda
    return Text('Build Results');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //Sugerencia de busqueda
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.location_on),
          title: Text('Colocar ubicacion manualmente'),
          onTap: () {
            print('Something...');
            this.close(context, SearchResult(cancelo: false, manual: true));
          },
        ),
      ],
    );
  }
}
