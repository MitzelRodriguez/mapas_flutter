part of 'busqueda_bloc.dart';

@immutable
abstract class BusquedaEvent {}

//eventos

class OnActivarMarcadorManual extends BusquedaEvent {}

class OnDesactivarMarcadorManual extends BusquedaEvent {}
