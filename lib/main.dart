import 'package:app_a/1_actualizarDatos.dart';
import 'package:app_a/Ingreso%20y%20Registro/autenticacion.dart';
import 'package:app_a/Ingreso%20y%20Registro/ingreso.dart';
import 'package:app_a/Ingreso%20y%20Registro/registro.dart';
import 'package:app_a/principal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '2_transferenciaDeDatos.dart';
//adb connect 192.168.0.11:5555
int colorBox = 0xffff5722;

//Tamaño de letra

double Titulo = 22;
double SubTitulo = 19;
double Cuerpo = 16;
double Botones = 18;
double VentanaTitulo = 21;
double VentanaSubTitulo = 18;
double VentanaCuerpo = 15;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  My createState() => My();
}

class My extends State<MyApp> {
  final firebase = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  transferencia_de_Datos datos = new transferencia_de_Datos();

  ValidacionIngreso(transferencia_de_Datos datos) async {
    String respuesta = "NO";

    try {
      String? deviceId = await autenticacion().OptenerID();
      CollectionReference ref = FirebaseFirestore.instance.collection("Dispositivos");
      QuerySnapshot base = await ref.get();
      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios");
      QuerySnapshot base2 = await ref2.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if(cursor.get("Activo") == "SI") {
            for (var cursor2 in base2.docs) {
              if(cursor2.get("Correo") == cursor.get("Correo") && cursor2.get("Contrasena") == cursor.get("Contrasena") ) {
                actualizarDatos(datos).UsuariosDispositivo(cursor2.get("Contrasena"),cursor2.get("Correo"),cursor2.get("FechaRegistro"),cursor2.get("FechaUltimoIngreso"),cursor2.get("ID"),deviceId,cursor2.get("Usuario"),cursor2.id);
                respuesta = "SI";
              }
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }

    print(respuesta);
    if(respuesta == "SI") {
      ValorDeudasRestantes();
    } else if (respuesta == "NO") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ingreso(datos)));
    }
  }

  ValorDeudasRestantes() async {

    String Valores = "";
    int SumaTotalDeudas = 0;
    int SumaTotalAbonos = 0;

    try{
      Valores = "";
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot deudas = await ref.get();

      for(var cursor in deudas.docs){
        Valores = cursor.get("DeudaTotal");
        SumaTotalDeudas += int.parse(Valores);
      }

      SumaTotalDeudas = int.parse(SumaTotalDeudas.toString().replaceAll(".0", ""));

      Valores = "";
      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot abonos = await ref2.get();

      for(var cursor in abonos.docs){
        Valores = cursor.get("AbonoTotal");
        SumaTotalAbonos += int.parse(Valores);
      }

      SumaTotalAbonos = int.parse(SumaTotalAbonos.toString().replaceAll(".0", ""));

      datos.ValorDeudaRestante = (SumaTotalDeudas-SumaTotalAbonos).toString();
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
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("UsuariosPrestamos");
      QuerySnapshot prestamos = await ref.get();

      for(var cursor in prestamos.docs){
        Valores = cursor.get("PrestamoTotal");
        SumaTotalPrestamos += int.parse(Valores);
      }

      SumaTotalPrestamos = int.parse(SumaTotalPrestamos.toString().replaceAll(".0", ""));

      Valores = "";
      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("UsuariosPrestamos");
      QuerySnapshot abonos = await ref2.get();

      for(var cursor in abonos.docs){
        Valores = cursor.get("AbonoTotal");
        SumaTotalAbonos += int.parse(Valores);
      }

      SumaTotalAbonos = int.parse(SumaTotalAbonos.toString().replaceAll(".0", ""));

      datos.ValorPrestamoRestante = (SumaTotalPrestamos-SumaTotalAbonos).toString();
      Navigator.push(context, MaterialPageRoute(builder: (context) => principal(datos)));

    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold (
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
                  child: Text("BSCU", style: TextStyle(fontSize: 30, color: Colors.black)),
                )
              ]
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
                  child: Text("Ten el control de tu vida", style: TextStyle(fontSize: SubTitulo, color: Colors.black)),
                )
              ]
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  color: Colors.blue,
                  onPressed: () {
                    ValidacionIngreso(datos);
                  },
                  child: Text('Iniciar Sesion',
                    style: TextStyle(fontSize: Botones, color: Colors.white),
                  ),
                ),

                MaterialButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  color: Colors.red,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => registro()));
                  },
                  child: Text('Crear Cuenta',
                    style: TextStyle(fontSize: Botones, color: Colors.white),
                  ),
                ),
              ],
            )
          ]
        )
      )
    );
  }
}

