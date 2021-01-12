part of 'widgets.dart';

class MarcadorManual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 70,
          left: 20,
          child: CircleAvatar(
            maxRadius: 25,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black87,
              ),
              onPressed: () {},
            ),
          ),
        ),
        Center(
          child: Transform.translate(
            offset: Offset(0, -10),
            child: Icon(Icons.location_on, size: 50),
          ),
        ),

        //Boton de confirmar destino
      ],
    );
  }
}
