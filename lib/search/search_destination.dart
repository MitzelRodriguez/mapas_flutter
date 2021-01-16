import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:mapa_app/models/search_response.dart';
import 'package:mapa_app/models/search_result.dart';
import 'package:mapa_app/services/traffic_services.dart';

class SearchDestination extends SearchDelegate<SearchResult> {
  @override
  final String searchFieldLabel;
  final TrafficService _trafficService;
  final LatLng proximidad;
  final List<SearchResult> historial;

  SearchDestination(this.proximidad, this.historial)
      : this.searchFieldLabel = 'Buscar...',
        this._trafficService = new TrafficService();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () => this.query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    print('Build Leading');
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => this.close(context, SearchResult(cancelo: true)));
  }

  @override
  Widget buildResults(BuildContext context) {
    //Resultados de busqueda
    print('buildResults');
    return _construirResultadosSugerencias();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    print('buildSuggestions');
    if (this.query.length == 0) {
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
          ...this
              .historial
              .map((result) => ListTile(
                    leading: Icon(Icons.history),
                    title: Text(result.nombreDestino),
                    subtitle: Text(result.descripcion),
                    onTap: () {
                      this.close(context, result);
                    },
                  ))
              .toList(),
        ],
      );
    }
    return this._construirResultadosSugerencias();
  }

  Widget _construirResultadosSugerencias() {
    print('construir resultados sugerencias');
    if (this.query == 0) {
      return Container();
    }

    this
        ._trafficService
        .getResultadosPorQuery(this.query.trim(), this.proximidad);

    //llamar servicio
    return StreamBuilder(
        stream: this._trafficService.sugerenciasStream,
        builder:
            (BuildContext context, AsyncSnapshot<SearchResponse> snapshot) {
          print('Snapshot: $snapshot');
          if (snapshot.hasData) {
            final lugares = snapshot.data.features;

            if (lugares.length == 0) {
              return ListTile(
                title: Text('No hay resultados con $query'),
              );
            }

            return ListView.separated(
              itemCount: lugares.length,
              separatorBuilder: (_, i) => Divider(),
              itemBuilder: (_, i) {
                final lugar = lugares[i];
                return ListTile(
                  leading: Icon(Icons.place),
                  title: Text(lugar.textEs),
                  subtitle: Text(lugar.placeNameEs),
                  onTap: () {
                    this.close(
                        context,
                        SearchResult(
                          cancelo: false,
                          manual: false,
                          position: LatLng(lugar.center[1], lugar.center[0]),
                          nombreDestino: lugar.textEs,
                          descripcion: lugar.placeNameEs,
                        ));
                  },
                );
              },
            );
          } else {
            print('noHAsData');
          }
        });
  }
}
