import 'package:flutter/material.dart';

int colorAppBar = 0xffff5722;
int colorBody = 0xffffffff;
int colorBox = 0xffff5722;

class busqueda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Color(colorAppBar),
        title: Text('Modulo de busqueda'),
      ),

      backgroundColor: Color(colorBody),

      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 25, top: 25, right: 25, bottom: 0),
              child: Container(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Producto a buscar',
                    hintText: 'Por favor ingrese el producto a buscar',
                  ),
                ),
              ),
            ),

            filtrosBusqueda(),

            Padding(padding: EdgeInsets.only(top: 10),
              child: MaterialButton(
                  onPressed: () {
                    print('Presione el boton');
                  },
                  color: Color(colorBox),
                  textColor: Colors.white,
                  child: Text('Buscar')
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Filtros de busqueda
enum SingingCharacter { Tienda, Producto }
class filtrosBusqueda extends StatefulWidget {
  const filtrosBusqueda({Key? key}) : super(key: key);

  @override
  State<filtrosBusqueda> createState() => _filtrosBusqueda();
}
class _filtrosBusqueda extends State<filtrosBusqueda> {
  SingingCharacter? _character = SingingCharacter.Tienda;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
              children: [
                Padding(padding: EdgeInsets.only(left: 50, top: 5, right: 0, bottom: 5),
                  child: ListTile(
                    title: const Text('Tienda'),
                    leading: Radio<SingingCharacter>(
                      value: SingingCharacter.Tienda,
                      groupValue: _character,
                      onChanged: (SingingCharacter? value) {
                        setState(() {
                          _character = value;
                        });
                      },
                    ),
                  ),
                ),
              ]
          ),
        ),
        Expanded(
          child: Column(
              children: [
                Padding(padding: EdgeInsets.only(left: 0, top: 5, right: 5, bottom: 5),
                  child: ListTile(
                    title: const Text('Producto'),
                    leading: Radio<SingingCharacter>(
                      value: SingingCharacter.Producto,
                      groupValue: _character,
                      onChanged: (SingingCharacter? value) {
                        setState(() {
                          _character = value;
                        });
                      },
                    ),
                  ),
                ),
              ]
          ),
        ),
      ],
    );
  }
}