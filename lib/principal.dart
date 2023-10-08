import 'package:app_a/2_transferenciaDeDatos.dart';
import 'package:app_a/Deudas,%20Prestamos,%20Ahorros,%20Informe%20y%20Movimientos/ahorros.dart';
import 'package:app_a/Deudas,%20Prestamos,%20Ahorros,%20Informe%20y%20Movimientos/deudas.dart';
import 'package:app_a/Deudas,%20Prestamos,%20Ahorros,%20Informe%20y%20Movimientos/informe.dart';
import 'package:app_a/Deudas,%20Prestamos,%20Ahorros,%20Informe%20y%20Movimientos/movimientos.dart';
import 'package:app_a/Deudas,%20Prestamos,%20Ahorros,%20Informe%20y%20Movimientos/prestamos.dart';
import 'package:app_a/Ingreso%20y%20Registro/autenticacion.dart';
import 'package:app_a/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class principal extends StatefulWidget {
  final transferencia_de_Datos datos;
  const principal(this.datos, {Key? key}) : super(key: key);

  @override
  principal_App createState() => principal_App();
}

class principal_App extends State<principal> {
  final firebase = FirebaseFirestore.instance;
  String now = DateFormat.yMMMEd().format(DateTime.now()) + ", " + DateFormat.jm().format(DateTime.now());

  void _onItemTapped(int index) {
    setState(() {
      widget.datos.Pantalla = index;
    });
  }

  CerrarSesion() async{

    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios");
      QuerySnapshot usuario = await ref.get();
      String? deviceId = await autenticacion().OptenerID();
      print(deviceId);

      if(usuario.docs.length != 0){
        for(var cursor in usuario.docs){
          if(FirebaseAuth.instance.currentUser!.uid == cursor.get("ID")) {
            await firebase
                .collection("Usuarios").doc(cursor.id)
                .set({
              "Contrasena": cursor.get("Contrasena"),
              "Correo": cursor.get("Correo"),
              "FechaRegistro": cursor.get("FechaRegistro"),
              "FechaUltimoIngreso": now,
              "ID": cursor.get("ID"),
              "Usuario": cursor.get("Usuario"),
            });
            await firebase
                .collection("Dispositivos").doc(deviceId)
                .set({
              "Activo": "NO",
              "ID-Dispositivo": deviceId,
              "Usuario": cursor.get("Usuario"),
              "Correo": cursor.get("Correo"),
              "Contrasena": cursor.get("Contrasena"),
            });
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
          }
        }
      }
      else{
        mensaje("Error", "Coleccion Vacia");
      }
    }catch(e){
      print(e);
    }
  }

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  Widget build(BuildContext context) {

    //Menu Horizontal
    final List<Widget> _widgetOptions = <Widget>[
      deudas(widget.datos),
      prestamos(widget.datos),
      ahorros(widget.datos),
      informe(widget.datos),
      movimientos(widget.datos),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.only(left: 13, top: 43, right: 13, bottom: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white,
                                child: Text(widget.datos.Usuario.substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 45)),
                              ),
                              Padding(padding: EdgeInsets.only(left: 10, top: 0, right: 0, bottom: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.datos.Usuario, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
                                    Text(widget.datos.Correo, style: TextStyle(color: Colors.white, fontSize: 16)),
                                  ],
                                )
                              )
                            ],
                          ),
                          Text('\nFecha Registro: '+widget.datos.FechaRegistro, style: TextStyle(color: Colors.white, fontSize: 15)),
                          Text('Ultimo Ingreso: '+widget.datos.FechaUltimoIngreso, style: TextStyle(color: Colors.white, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.home,
                ),
                title: Text('Deudas, Prestamos y Ahorros', style: TextStyle(fontSize: Cuerpo)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.train,
                ),
                title: Text('Gastos Mensuales', style: TextStyle(fontSize: Cuerpo)),
                onTap: () {
                  //TraerMeses();
                  Navigator.pop(context);
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => Gastos_Mensuales(widget.datos)));
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.train,
                ),
                title: Text('Cerrar Sesion', style: TextStyle(fontSize: Cuerpo)),
                onTap: () {
                  CerrarSesion();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.train,
                ),
                title: Text('Acerca', style: TextStyle(fontSize: Cuerpo)),
                onTap: () {

                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: Text('BSCU', style: TextStyle(fontSize: Titulo)),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.update),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => principal(widget.datos)));
                },
              ),
            ]
        ),
        body: Center(
          child: _widgetOptions.elementAt(widget.datos.Pantalla),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Deudas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center_outlined),
              label: 'Prestamos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined),
              label: 'Ahorros',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.request_page_outlined),
              label: 'Informe',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_edu),
              label: 'Movimientos',
            ),
          ],
          currentIndex: widget.datos.Pantalla,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void mensaje(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (buildcontext) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: <Widget>[],
        );
      }
    );
  }
}