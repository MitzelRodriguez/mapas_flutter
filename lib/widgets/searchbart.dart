part of 'widgets.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusquedaBloc, BusquedaState>(
      builder: (context, state) {
        if (state.seleccionManual) {
          return Container();
        } else {
          return FadeInDown(
              duration: Duration(milliseconds: 300),
              child: buildSearchBar(context));
        }
      },
    );
  }

  Widget buildSearchBar(BuildContext context) {
    final widthSize = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        width: widthSize,
        child: GestureDetector(
          onTap: () async {
            final proximidad =
                BlocProvider.of<MiUbicacionBloc>(context).state.ubicacion;
            final historial =
                BlocProvider.of<BusquedaBloc>(context).state.historial;

            final resultado = await showSearch(
                context: context,
                delegate: SearchDestination(proximidad, historial));
            this.retornoBusqueda(context, resultado);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            width: double.infinity,
            child: Text(
              'Donde quieres ir?',
              style: TextStyle(color: Colors.black87),
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 5))
                ]),
          ),
        ),
      ),
    );
  }

  void retornoBusqueda(BuildContext context, SearchResult result) async {
    print('cancelo:${result.cancelo}');
    print('manual: ${result.manual}');
    if (result.cancelo) return;

    if (result.manual) {
      BlocProvider.of<BusquedaBloc>(context).add(OnActivarMarcadorManual());
      return;
    }

    calculandoAlerta(context);

    //Calcular la ruta en base al valor: Result
    final trafficService = new TrafficService();
    final mapaBloc = BlocProvider.of<MapaBloc>(context);

    final inicio = BlocProvider.of<MiUbicacionBloc>(context).state.ubicacion;
    final destino = result.position;

    final drivingResponse =
        await trafficService.getCoordsInicioYDestino(inicio, destino);

    final geometry = drivingResponse.routes[0].geometry;
    final duration = drivingResponse.routes[0].duration;
    final distancia = drivingResponse.routes[0].distance;
    final nombreDestino = result.nombreDestino;

    //Decodificar los puntos
    final points = Poly.Polyline.Decode(encodedString: geometry, precision: 6);

    //Listado de Lat y Long
    final List<LatLng> rutaCoordenadas = points.decodedCoords
        .map((points) => LatLng(points[0], points[1]))
        .toList();

    //Llamar evento para crear la ruta de inicio y fin
    mapaBloc.add(OnCrearRutaInicioDestino(
      rutaCoordenadas,
      distancia,
      duration,
      nombreDestino,
    ));

    Navigator.of(context).pop();

    //Agregar resultado al historial
    final busquedaBloc = BlocProvider.of<BusquedaBloc>(context);

    busquedaBloc.add(OnAgregarHistorial(result));
  }
}
