import 'package:app_a/Ingreso%20y%20Registro/autenticacion.dart';
import 'package:app_a/2_transferenciaDeDatos.dart';
import 'package:app_a/1_actualizarDatos.dart';
import 'package:app_a/main.dart';
import 'package:app_a/principal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ingreso extends StatefulWidget {
  final transferencia_de_Datos datos;
  const ingreso(this.datos, {Key? key}) : super(key: key);

  @override
  ingreso_App createState() => ingreso_App();
}

class ingreso_App extends State<ingreso> {
  final firebase = FirebaseFirestore.instance;
  TextEditingController usuario = TextEditingController();
  TextEditingController correo = TextEditingController();
  TextEditingController contrasena = TextEditingController();
  TextEditingController verificar_contrasena = TextEditingController();
  String now = DateFormat.yMMMEd().format(DateTime.now()) + ", " + DateFormat.jm().format(DateTime.now());
  int baningreso = 0;

  IngresoUsuario() async {
    try {
      String? deviceId = await autenticacion().OptenerID();
      print(deviceId);
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios");
      QuerySnapshot usuarios = await ref.get();
      if(usuarios.docs.length != 0) {
        if (correo.text != "" && contrasena.text != "") {
          dynamic Iddispositivo = await autenticacion().Ingreso(correo.text, contrasena.text);
          if(Iddispositivo != null) {
            if(Iddispositivo == "Usuario No Encontrado") {
              mensaje("Error", "Usuario No Encontrado");
            } else if (Iddispositivo == "Contraseña Incorrecta") {
              mensaje("Error", "Contraseña Incorrecta");
            } else{
              for(var cursor in usuarios.docs) {
                if(FirebaseAuth.instance.currentUser!.uid == cursor.get("ID")) {
                  print("Usuario Encontrado");
                  correo.clear();
                  contrasena.clear();
                  await firebase
                      .collection("Dispositivos").doc(deviceId)
                      .set({
                    "Activo": "SI",
                    "ID-Dispositivo": deviceId,
                    "Usuario": cursor.get("Usuario"),
                    "Correo": cursor.get("Correo"),
                    "Contrasena": cursor.get("Contrasena"),
                  });
                  actualizarDatos(widget.datos).UsuariosDispositivo(cursor.get("Contrasena"),cursor.get("Correo"),cursor.get("FechaRegistro"),cursor.get("FechaUltimoIngreso"),cursor.get("ID"),deviceId,cursor.get("Usuario"),cursor.id);
                  ValorDeudasRestantes();
                }
              }
            }
          } else {
            print("Usuario NO Encontrado");
          }
        } else {
          mensaje("Error", "Datos incompletos");
        }
      } else {
        mensaje("Error", "Coleccion Vacia");
      }
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  ValorDeudasRestantes() async {

    String Valores = "";
    int SumaTotalDeudas = 0;
    int SumaTotalAbonos = 0;

    try{
      Valores = "";
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot deudas = await ref.get();

      for(var cursor in deudas.docs){
        Valores = cursor.get("DeudaTotal");
        SumaTotalDeudas += int.parse(Valores);
      }

      SumaTotalDeudas = int.parse(SumaTotalDeudas.toString().replaceAll(".0", ""));

      Valores = "";
      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot abonos = await ref2.get();

      for(var cursor in abonos.docs){
        Valores = cursor.get("AbonoTotal");
        SumaTotalAbonos += int.parse(Valores);
      }

      SumaTotalAbonos = int.parse(SumaTotalAbonos.toString().replaceAll(".0", ""));

      widget.datos.ValorDeudaRestante = (SumaTotalDeudas-SumaTotalAbonos).toString();
      ValorPrestamosRestantes();
    }catch(e){
      print(e);
    }
  }

  ValorPrestamosRestantes() async {

    String Valores = "";
    int SumaTotalPrestamos = 0;
    int SumaTotalAbonos = 0;

    try{
      Valores = "";
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosPrestamos");
      QuerySnapshot prestamos = await ref.get();

      for(var cursor in prestamos.docs){
        Valores = cursor.get("PrestamoTotal");
        SumaTotalPrestamos += int.parse(Valores);
      }

      SumaTotalPrestamos = int.parse(SumaTotalPrestamos.toString().replaceAll(".0", ""));

      Valores = "";
      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosPrestamos");
      QuerySnapshot abonos = await ref2.get();

      for(var cursor in abonos.docs){
        Valores = cursor.get("AbonoTotal");
        SumaTotalAbonos += int.parse(Valores);
      }

      SumaTotalAbonos = int.parse(SumaTotalAbonos.toString().replaceAll(".0", ""));

      widget.datos.ValorPrestamoRestante = (SumaTotalPrestamos-SumaTotalAbonos).toString();
      Navigator.push(context, MaterialPageRoute(builder: (context) => principal(widget.datos)));

    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BSCU', style: TextStyle(fontSize: Titulo)),
      ),
      body: Column(
        children: [
          //Iniciar Sesion
          Padding(padding: EdgeInsets.only(left: 10, top: 30, right: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Titulo
                Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: Text('Iniciar Sesion\n',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: SubTitulo),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                //Correo
                Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                  child: TextField(
                    controller: correo,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        labelText: "Correo",
                        labelStyle: TextStyle(fontSize: Cuerpo),
                        hintText: "Digite el correo",
                        hintStyle: TextStyle(fontSize: Cuerpo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        )
                    ),
                  ),
                ),
                //Contraseña
                Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                  child: TextField(
                    controller: contrasena,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Contraseña",
                        labelStyle: TextStyle(fontSize: Cuerpo),
                        hintText: "Digite la contraseña",
                        hintStyle: TextStyle(fontSize: Cuerpo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        )
                    ),
                  ),
                ),
                //Ingresar o Cancelar
                Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          color: Colors.blue,
                          onPressed: () {
                            IngresoUsuario();
                          },
                          child: Text('Ingresar',
                            style: TextStyle(fontSize: Botones, color: Colors.white),
                          ),
                        ),

                        MaterialButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          color: Colors.red,
                          onPressed: () {
                            correo.text = "";
                            contrasena.text = "";
                          },
                          child: Text('Cancelar',
                            style: TextStyle(fontSize: Botones, color: Colors.white),
                          ),
                        ),
                      ]
                  ),
                ),
              ],
            ),
          ),
        ]
      )
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