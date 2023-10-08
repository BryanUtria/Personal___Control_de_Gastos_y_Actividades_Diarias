import 'package:app_a/Borrar/Deudas_y_Deudores.dart';
import 'package:app_a/Ingreso%20y%20Registro/autenticacion.dart';
import 'package:app_a/2_transferenciaDeDatos.dart';
import 'package:app_a/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Ingreso_y_Registro extends StatefulWidget {
  final transferencia_de_Datos datos;
  const Ingreso_y_Registro(this.datos, {Key? key}) : super(key: key);

  @override
  Ingreso_y_Registro_App createState() => Ingreso_y_Registro_App();
}

class Ingreso_y_Registro_App extends State<Ingreso_y_Registro> {
  final firebase = FirebaseFirestore.instance;
  TextEditingController usuario = TextEditingController();
  TextEditingController correo = TextEditingController();
  TextEditingController contrasena = TextEditingController();
  TextEditingController verificar_contrasena = TextEditingController();
  String now = DateFormat.yMMMEd().format(DateTime.now()) + ", " + DateFormat.jm().format(DateTime.now());
  int baningreso = 0;
  transferencia_de_Datos datos = new transferencia_de_Datos();

  ValorDeudasRestantes() async {

    String Valores = "";
    int SumaTotalDeudas = 0;
    int SumaTotalAbonos = 0;

    try{
      Valores = "";
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot deudas = await ref.get();

      for(var cursor in deudas.docs){
        Valores = cursor.get("DeudaTotal");
        SumaTotalDeudas += int.parse(Valores);
      }

      SumaTotalDeudas = int.parse(SumaTotalDeudas.toString().replaceAll(".0", ""));

      Valores = "";
      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot abonos = await ref2.get();

      for(var cursor in abonos.docs){
        Valores = cursor.get("AbonoTotal");
        SumaTotalAbonos += int.parse(Valores);
      }

      SumaTotalAbonos = int.parse(SumaTotalAbonos.toString().replaceAll(".0", ""));

      widget.datos.ValorDeudaRestante = (SumaTotalDeudas-SumaTotalAbonos).toString();
    }catch(e){
      print(e);
    }
  }

  RegistroUsuario() async {

    if (correo.text != "" && contrasena.text != "" && verificar_contrasena.text != "") {
      if (contrasena.text == verificar_contrasena.text) {
        UserCredential Credencial = await autenticacion().Registro(correo.text, contrasena.text);
        if(Credencial != null) {
          String? deviceId = await autenticacion().OptenerID();
          print(deviceId);
          print("Usuario Registrado");
          await firebase
              .collection("Usuarios").doc(deviceId).collection("UsuariosDispositivo")
              .doc()
              .set({
            "ID": FirebaseAuth.instance.currentUser!.uid,
            "Activo": "NO",
            "FechaRegistro": now,
            "FechaUltimoIngreso": now,
            "ID-Dispositivo": deviceId,
            "Usuario": usuario.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
          });
          mensaje("Exito", "Registro Realizado");
          correo.text = "";
          contrasena.text = "";
          verificar_contrasena.text = "";
          usuario.text = "";
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

  IngresoUsuario() async {

    try {
      String? deviceId = await autenticacion().OptenerID();
      print(deviceId);
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(deviceId).collection("UsuariosDispositivo");
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
                  datos.docUsuario = cursor.id;
                  datos.docDispositivo = deviceId!;
                  datos.CorreoUsuario = FirebaseAuth.instance.currentUser!.email!;
                  datos.FechaRegistroUsuario = cursor.get("FechaRegistro");
                  datos.FechaUltimoIngresoUsuario = cursor.get("FechaUltimoIngreso");
                  datos.NombreUsuario = cursor.get("Usuario");
                  correo.clear();
                  contrasena.clear();
                  await firebase
                      .collection("Usuarios").doc(deviceId).collection("UsuariosDispositivo")
                      .doc(datos.docUsuario)
                      .set({
                    "Activo": "SI",
                    "FechaRegistro": cursor.get("FechaRegistro"),
                    "FechaUltimoIngreso": cursor.get("FechaUltimoIngreso"),
                    "ID": cursor.get("ID"),
                    "ID-Dispositivo": cursor.get("ID-Dispositivo"),
                    "Usuario": cursor.get("Usuario"),
                  });
                  ValorDeudasRestantes();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Deudas_y_Deudores(widget.datos)));
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(child: Text('Iniciar Sesion', style: TextStyle(fontSize: SubTitulo))),
                Tab(child: Text('Crear cuenta', style: TextStyle(fontSize: SubTitulo))),
              ],
            ),
            title: Text('Control de Actividades', style: TextStyle(fontSize: Titulo)),
          ),
          body: TabBarView(
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
                    Padding
                      (padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MaterialButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                              color: Colors.blue,
                              onPressed: () {
                                RegistroUsuario();
                              },
                              child: Text('Registrar',
                                style: TextStyle(fontSize: Botones, color: Colors.white),
                              ),
                            ),

                            MaterialButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                              color: Colors.red,
                              onPressed: () {
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
        )
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