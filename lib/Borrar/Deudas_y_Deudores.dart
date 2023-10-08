import 'package:app_a/Borrar/Gastos%20Mensuales/Gastos%20Mensuales.dart';
import 'package:app_a/Borrar/Ingreso%20y%20Registro.dart';
import 'package:app_a/2_transferenciaDeDatos.dart';
import 'package:app_a/Deudas,%20Prestamos,%20Ahorros,%20Informe%20y%20Movimientos/deudas.dart';
import 'package:app_a/Deudas,%20Prestamos,%20Ahorros,%20Informe%20y%20Movimientos/informe.dart';
import 'package:app_a/Deudas,%20Prestamos,%20Ahorros,%20Informe%20y%20Movimientos/prestamos.dart';
import 'package:app_a/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Deudas_y_Deudores extends StatefulWidget {
  final transferencia_de_Datos datos;
  const Deudas_y_Deudores(this.datos, {Key? key}) : super(key: key);

  @override
  Deudas_y_Deudores_App createState() => Deudas_y_Deudores_App();
}

class Deudas_y_Deudores_App extends State<Deudas_y_Deudores> {
  int _selectedIndex = 0;
  final firebase = FirebaseFirestore.instance;
  String now = DateFormat.yMMMEd().format(DateTime.now()) + ", " + DateFormat.jm().format(DateTime.now());

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  CerrarSesion() async{

    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo");
      QuerySnapshot usuario = await ref.get();

      if(usuario.docs.length != 0){
        for(var cursor in usuario.docs){
          if(widget.datos.docUsuario == cursor.id) {
            await firebase
                .collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo")
                .doc(widget.datos.docUsuario)
                .set({
              "Activo": "NO",
              "FechaRegistro": cursor.get("FechaRegistro"),
              "FechaUltimoIngreso": now,
              "ID": cursor.get("ID"),
              "ID-Dispositivo": cursor.get("ID-Dispositivo"),
              "Usuario": cursor.get("Usuario"),
            });
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => Ingreso_y_Registro(widget.datos)));
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

  TraerMeses() async {
    var Mes;
    final Meses = ['Agregar Mes'];

    try{
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales");
      QuerySnapshot usuario = await ref.get();

      if(usuario.docs.length != 0){
        for(var cursor in usuario.docs){
          Mes = cursor.get("Mes");
          Meses.add(Mes);
        }
        widget.datos.MesesGastos = Meses;
        widget.datos.MesDropdownValue = 'Agregar Mes';
      }
      else{
        mensaje("Error", "Coleccion Vacia");
      }
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    //Menu Horizontal
    final List<Widget> _widgetOptions = <Widget>[
      deudas(widget.datos),
      prestamos(widget.datos),
      informe(widget.datos),
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
                                child: Text(widget.datos.CorreoUsuario.substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 45)),
                              ),
                              Padding(padding: EdgeInsets.only(left: 10, top: 0, right: 0, bottom: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.datos.NombreUsuario, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
                                    Text(widget.datos.CorreoUsuario, style: TextStyle(color: Colors.white, fontSize: 16)),
                                  ],
                                )
                              )
                            ],
                          ),
                          Text('\nFecha Registro: '+widget.datos.FechaRegistroUsuario, style: TextStyle(color: Colors.white, fontSize: 15)),
                          Text('Ultimo Ingreso: '+widget.datos.FechaUltimoIngresoUsuario, style: TextStyle(color: Colors.white, fontSize: 15)),
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
                title: Text('Deudas, Prestamos, Ahorros, Informe y Movimientos', style: TextStyle(fontSize: Cuerpo)),
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
                  TraerMeses();
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Gastos_Mensuales(widget.datos)));
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
          title: Text('Control de Deudas, Prestamos, Ahorros, Informe y Movimientos', style: TextStyle(fontSize: Titulo)),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Deudas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center),
              label: 'Deudores',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Informe',
            ),
          ],
          currentIndex: _selectedIndex,
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