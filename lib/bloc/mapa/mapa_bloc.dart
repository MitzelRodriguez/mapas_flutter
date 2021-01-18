import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart' show Colors, Offset;
import 'package:meta/meta.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapa_app/themes/uber_map_theme.dart';

part 'mapa_event.dart';
part 'mapa_state.dart';

class MapaBloc extends Bloc<MapaEvent, MapaState> {
  MapaBloc() : super(MapaState());

  //Controlador del mapa
  GoogleMapController _mapController;

  //Polylines
  Polyline _miRuta = new Polyline(
    polylineId: PolylineId('mi_ruta'),
    color: Colors.transparent,
    width: 4,
  );

  //Polyline de la ruta a seguir
  Polyline _rutaDestino = new Polyline(
    polylineId: PolylineId('ruta_destino'),
    color: Colors.blueAccent,
    width: 4,
  );

  void initMapa(GoogleMapController controller) {
    if (!state.mapaListo) {
      this._mapController = controller;
      this._mapController.setMapStyle(
          jsonEncode(uberMapTheme)); //manejar como string json de themaMap
      add(OnMapaListo());
    }
  }

  void moverCamera(LatLng destino) {
    final cameraUpdate = CameraUpdate.newLatLng(destino);
    this._mapController?.animateCamera(cameraUpdate);
  }

  @override
  Stream<MapaState> mapEventToState(
    MapaEvent event,
  ) async* {
    if (event is OnMapaListo) {
      yield state.copyWith(mapaListo: true);
    } else if (event is OnLocationUpdate) {
      yield* this._onLocationUpdate(event);
    } else if (event is OnMarcarRecorrido) {
      yield* this._onMarcarRecorrido(event);
    } else if (event is OnSeguirUbicacion) {
      yield* this._onSeguirUbicacion(event);
    } else if (event is OnMovioMapa) {
      yield state.copyWith(ubicacionCentral: event.centroMapa);
    } else if (event is OnCrearRutaInicioDestino) {
      yield* this._onCrearRutaInicioDestino(event);
    }
  }

  Stream<MapaState> _onLocationUpdate(OnLocationUpdate event) async* {
    if (state.seguirUbicacion) {
      this.moverCamera(event.ubicacion);
    }

    final points = [...this._miRuta.points, event.ubicacion];
    this._miRuta = this._miRuta.copyWith(pointsParam: points);

    final currentPolylines = state.polylines;
    currentPolylines['mi_ruta'] = this._miRuta;

    yield state.copyWith(polylines: currentPolylines);
  }

  Stream<MapaState> _onSeguirUbicacion(OnSeguirUbicacion event) async* {
    if (!state.seguirUbicacion) {
      this.moverCamera(this._miRuta.points[this._miRuta.points.length - 1]);
    }
    //emitir un nuevo estado de state.copyWith
    yield state.copyWith(seguirUbicacion: !state.seguirUbicacion);
  }

  Stream<MapaState> _onMarcarRecorrido(OnMarcarRecorrido event) async* {
    if (!state.dibujarRecorrido) {
      this._miRuta = this._miRuta.copyWith(colorParam: Colors.black87);
    } else {
      this._miRuta = this._miRuta.copyWith(colorParam: Colors.transparent);
    }

    final currentPolylines = state.polylines;
    currentPolylines['mi_ruta'] = this._miRuta;

    yield state.copyWith(
        dibujarRecorrido: !state.dibujarRecorrido, polylines: currentPolylines);
  }

  Stream<MapaState> _onCrearRutaInicioDestino(
      OnCrearRutaInicioDestino event) async* {
    this._rutaDestino =
        this._rutaDestino.copyWith(pointsParam: event.rutaCoordenadas);

    final currentPolylines = state.polylines;
    currentPolylines['ruta_destino'] = this._rutaDestino;

    //Marcadores
    final markerInicio = new Marker(
      markerId: MarkerId('inicio'),
      position: event.rutaCoordenadas[0],
      infoWindow: InfoWindow(
        title: 'Origen',
        snippet: 'Punto de origen',
      ),
    );

    double kilometros = event.distancia / 1000;
    kilometros = ((kilometros * 100).floor().toDouble()) / 100;

    final markerFinal = new Marker(
      markerId: MarkerId('fin'),
      position: event.rutaCoordenadas[
          event.rutaCoordenadas.length - 1], //obtener ultima coordenada
      infoWindow: InfoWindow(
        title: event.nombreDestino,
        snippet: 'Duracion: ${(event.duracion / 60).floor()} minutos' +
            ' Distancia: ${kilometros}Km',
      ),
    );

    final newMarkers = {...state.markers}; // copia de marcadores

    //add marcador
    newMarkers['inicio'] = markerInicio;
    newMarkers['fin'] = markerFinal;

    Future.delayed(Duration(milliseconds: 300)).then(
      (value) => _mapController.showMarkerInfoWindow(MarkerId('fin')),
    );

    yield state.copyWith(
      polylines: currentPolylines,
      markers: newMarkers,
    );
  }
}
