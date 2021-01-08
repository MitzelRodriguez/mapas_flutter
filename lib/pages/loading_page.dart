import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as Geolocator;
import 'package:mapa_app/helpers/helpers.dart';
import 'package:mapa_app/pages/acceso_gps_page.dart';
import 'package:mapa_app/pages/mapa_page.dart';
import 'package:permission_handler/permission_handler.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // ignore: deprecated_member_use
      if (await Geolocator.isLocationServiceEnabled()) {
        Navigator.pushReplacement(
            context, navegarMapaFadeIn(context, MapaPage()));
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: this.checkGPSyLocation(context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Center(
            child: Text(snapshot.data),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }
      },
    ));
  }

  Future checkGPSyLocation(BuildContext context) async {
    //Permiso GPS
    final permisoGPS = await Permission.location.isGranted;
    //GPS Activo
    // ignore: deprecated_member_use
    final gpsActivo = await Geolocator.isLocationServiceEnabled();

    if (permisoGPS && gpsActivo) {
      Navigator.pushReplacement(
          context, navegarMapaFadeIn(context, MapaPage()));
      return '';
    } else if (!permisoGPS) {
      Navigator.pushReplacement(
          context, navegarMapaFadeIn(context, AccesoGPSPage()));
      return 'Active los permisos del gps';
    } else if (!gpsActivo) {
      return 'Active el gps';
    }
  }
} //class LoadingPage extends StatelessWidget
