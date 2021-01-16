part of 'widgets.dart';

class BtnSeguirUbicacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapaBloc, MapaState>(
      builder: (context, state) => this._crearBoton(context, state),
    );
  }

  Widget _crearBoton(BuildContext context, MapaState state) {
    final mapaBloc = BlocProvider.of<MapaBloc>(context);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        maxRadius: 25,
        child: IconButton(
            icon: Icon(
              mapaBloc.state.seguirUbicacion
                  ? Icons.directions_run
                  : Icons.accessibility_new,
              color: Colors.black,
            ),
            onPressed: () {
              mapaBloc.add(OnSeguirUbicacion());
            }),
      ),
    );
  }
}
