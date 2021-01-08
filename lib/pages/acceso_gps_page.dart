import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AccesoGPSPage extends StatefulWidget {
  @override
  _AccesoGPSPageState createState() => _AccesoGPSPageState();
}

class _AccesoGPSPageState extends State<AccesoGPSPage>
    with WidgetsBindingObserver {
  bool popup = false;

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
    if (await Permission.location.isGranted) {
      Navigator.pushReplacementNamed(context, 'loading');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Es necesario el gps para usar esta app'),
            MaterialButton(
                child: Text('Solicitar Acceso',
                    style: TextStyle(color: Colors.white)),
                color: Colors.black,
                shape: StadiumBorder(),
                elevation: 0,
                splashColor: Colors.transparent,
                onPressed: () async {
                  popup = true;

                  //verificar permisos
                  final status = await Permission.location.request();
                  this.accesoGPS(status);

                  popup = false;
                })
          ],
        ),
      ),
    );
  }

  void accesoGPS(PermissionStatus status) async {
    switch (status) {
      case PermissionStatus.granted:
        await Navigator.pushReplacementNamed(context, 'loading');
        break;
      case PermissionStatus.undetermined:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        openAppSettings();
    }
  }
}
