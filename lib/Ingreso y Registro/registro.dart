import 'package:app_a/Ingreso%20y%20Registro/autenticacion.dart';
import 'package:app_a/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class registro extends StatefulWidget {
  const registro({Key? key}) : super(key: key);

  @override
  registro_App createState() => registro_App();
}

class registro_App extends State<registro> {
  final firebase = FirebaseFirestore.instance;
  TextEditingController usuario = TextEditingController();
  TextEditingController correo = TextEditingController();
  TextEditingController contrasena = TextEditingController();
  TextEditingController verificar_contrasena = TextEditingController();
  String now = DateFormat.yMMMEd().format(DateTime.now()) + ", " + DateFormat.jm().format(DateTime.now());
  int baningreso = 0;

  RegistroUsuario() async {
    if (correo.text != "" && contrasena.text != "" && verificar_contrasena.text != "") {
      if (contrasena.text == verificar_contrasena.text) {
        UserCredential Credencial = await autenticacion().Registro(correo.text, contrasena.text);
        if(Credencial != null) {
          String? deviceId = await autenticacion().OptenerID();
          print(deviceId);
          print("Usuario Registrado");
          await firebase
              .collection("Usuarios").doc()
              .set({
            "ID": FirebaseAuth.instance.currentUser!.uid,
            "FechaRegistro": now,
            "FechaUltimoIngreso": now,
            "Usuario": usuario.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
            "Correo": correo.text,
            "Contrasena": contrasena.text,
          });
          await firebase
              .collection("Dispositivos").doc(deviceId)
              .set({
            "Activo": "NO",
            "ID-Dispositivo": deviceId,
            "Usuario": usuario.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
            "Correo": correo.text,
            "Contrasena": contrasena.text,
          });
          Navigator.pop(context, 'Registro');
          mensaje("Exito", "Registro Realizado");
          usuario.text = "";
          correo.text = "";
          contrasena.text = "";
          verificar_contrasena.text = "";
        } else {
          print("Usuario No Registrado");
          mensaje("Error", "Registro No Realizado");
        }
      } else {
        mensaje("Error", "Contraseñas No Coinciden");
        contrasena.text = "";
        verificar_contrasena.text = "";
      }
    } else {
      mensaje("Error", "Datos incompletos");
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BSCU', style: TextStyle(fontSize: Titulo)),
      ),
      body: Column(
        children: [
          //Crear Cuenta
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
                        child: Text('Crear Cuenta\n',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: SubTitulo),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                //Usuario
                Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                  child: TextField(
                    controller: usuario,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        labelText: "Nombre",
                        labelStyle: TextStyle(fontSize: Cuerpo),
                        hintText: "Digite su nombre completo",
                        hintStyle: TextStyle(fontSize: Cuerpo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        )
                    ),
                  ),
                ),
                //Correo
                Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                  child: TextField(
                    controller: correo,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Correo",
                      labelStyle: TextStyle(fontSize: Cuerpo),
                      hintText: "Digite un correo",
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
                        hintText: "Digite una contraseña con 6 digitos al menos",
                        hintStyle: TextStyle(fontSize: Cuerpo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        )
                    ),
                  ),
                ),
                //Verifricar Contraseña
                Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                  child: TextField(
                    obscureText: true,
                    controller: verificar_contrasena,
                    decoration: InputDecoration(
                      labelText: "Verificar Contraseña",
                      labelStyle: TextStyle(fontSize: Cuerpo),
                      hintText: "Digite nuevamente la contraseña",
                      hintStyle: TextStyle(fontSize: Cuerpo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      )
                    ),
                  ),
                ),
                //Registrar o Cancelar
                Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                        color: Colors.blue,
                        onPressed: () {
                          RegistroUsuario();
                        },
                        child: Text('Registrar', style: TextStyle(fontSize: Botones, color: Colors.white)),
                      ),

                      MaterialButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                        color: Colors.red,
                        onPressed: () {
                          usuario.text = "";
                          correo.text = "";
                          contrasena.text = "";
                          verificar_contrasena.text = "";
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