import 'package:app_a/2_transferenciaDeDatos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class actualizarDatos {
  final transferencia_de_Datos datos;
  actualizarDatos(this.datos);
  String now = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());

  void UsuariosDispositivo (var Contrasena, var Correo, var FechaRegistro, var FechaUltimoIngreso, var ID, var IDDispositivo, var Usuario, var docUsuario) {
    datos.Contrasena = Contrasena;
    datos.Correo = Correo;
    datos.FechaRegistro = FechaRegistro;
    datos.FechaUltimoIngreso = FechaUltimoIngreso;
    datos.ID = ID;
    datos.IDDispositivo = IDDispositivo;
    datos.Usuario = Usuario;
    datos.docUsuario = docUsuario;
  }

  Future<void> Movim_RegistroClientesDeudas (var Nombre, var Telefono, var Notas) async {
    var Respuesta = "NO";

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("Movimientos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == Nombre) {
            Respuesta = "SI";
            datos.Movim_docMovim = cursor.id;
          }
        }
      }

      if(Respuesta == "SI"){
        await FirebaseFirestore.instance
            .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
            .doc(datos.Movim_docMovim)
            .set({
          "Nombre": Nombre,
          "FechaCreacion": now,
        });
      }else if(Respuesta == "NO"){
        await FirebaseFirestore.instance
            .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
            .doc()
            .set({
          "Nombre": Nombre,
          "FechaCreacion": now,
        });
        Movim_RegistroClientesDeudas(Nombre,Telefono,Notas);
      }

      if(Respuesta == "SI"){
        await FirebaseFirestore.instance
            .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
            .doc(datos.Movim_docMovim).collection("Deudas").doc()
            .set({
          "FechaMovimiento": now,
          "Descripcion": "Creacion de cliente",
          "Nombre": Nombre,
          "Telefono": Telefono,
          "Notas": Notas,
          "DeudaTotal": "",
          "AbonoTotal": "",
          "Observacion": "",
          "Valor": "",
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> Movim_ActualizarDatosDeudas (var Nombre, var Telefono, var Notas) async {
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("Movimientos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == Nombre) {
            await FirebaseFirestore.instance
                .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
                .doc(cursor.id).collection("Deudas").doc()
                .set({
              "FechaMovimiento": now,
              "Descripcion": "Actualizacion de datos del cliente",
              "Nombre": Nombre,
              "Telefono": Telefono,
              "Notas": Notas,
              "DeudaTotal": "",
              "AbonoTotal": "",
              "Observacion": "",
              "Valor": "",
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> Movim_EliminarDocClienteDeudas (var Nombre, var Telefono, var Notas, var DeudaTotal, var AbonoTotal) async {
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("Movimientos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == Nombre) {
            await FirebaseFirestore.instance
                .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
                .doc(cursor.id).collection("Deudas").doc()
                .set({
              "FechaMovimiento": now,
              "Descripcion": "Eliminacion del cliente",
              "Nombre": Nombre,
              "Telefono": Telefono,
              "Notas": Notas,
              "DeudaTotal": DeudaTotal,
              "AbonoTotal": AbonoTotal,
              "Observacion": "",
              "Valor": "",
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> Movim_RegistroDeuda (var Observacion, var Valor, var Nombre) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("Movimientos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == Nombre) {
            await FirebaseFirestore.instance
                .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
                .doc(cursor.id).collection("Deudas").doc()
                .set({
              "FechaMovimiento": now,
              "Descripcion": "Creacion de Deuda",
              "Nombre": "",
              "Telefono": "",
              "Notas": "",
              "DeudaTotal": "",
              "AbonoTotal": "",
              "Observacion": Observacion,
              "Valor": Valor,
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> Movim_ActualizarDatosDeuda (var Observacion, var Valor, var Nombre) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("Movimientos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == Nombre) {
            await FirebaseFirestore.instance
                .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
                .doc(cursor.id).collection("Deudas").doc()
                .set({
              "FechaMovimiento": now,
              "Descripcion": "Actualizacion de Deuda",
              "Nombre": "",
              "Telefono": "",
              "Notas": "",
              "DeudaTotal": "",
              "AbonoTotal": "",
              "Observacion": Observacion,
              "Valor": Valor,
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> Movim_EliminarDocDeuda (var Observacion, var Valor, var Nombre) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("Movimientos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == Nombre) {
            await FirebaseFirestore.instance
                .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
                .doc(cursor.id).collection("Deudas").doc()
                .set({
              "FechaMovimiento": now,
              "Descripcion": "Eliminacion de Deuda",
              "Nombre": "",
              "Telefono": "",
              "Notas": "",
              "DeudaTotal": "",
              "AbonoTotal": "",
              "Observacion": Observacion,
              "Valor": Valor,
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> Movim_RegistroAbonoDeuda (var Observacion, var Valor, var Nombre) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("Movimientos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == Nombre) {
            await FirebaseFirestore.instance
                .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
                .doc(cursor.id).collection("Deudas").doc()
                .set({
              "FechaMovimiento": now,
              "Descripcion": "Creacion de Abono",
              "Nombre": "",
              "Telefono": "",
              "Notas": "",
              "DeudaTotal": "",
              "AbonoTotal": "",
              "Observacion": Observacion,
              "Valor": Valor,
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> Movim_ActualizarDatosAbono (var Observacion, var Valor, var Nombre) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("Movimientos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == Nombre) {
            await FirebaseFirestore.instance
                .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
                .doc(cursor.id).collection("Deudas").doc()
                .set({
              "FechaMovimiento": now,
              "Descripcion": "Actualizacion de Abono",
              "Nombre": "",
              "Telefono": "",
              "Notas": "",
              "DeudaTotal": "",
              "AbonoTotal": "",
              "Observacion": Observacion,
              "Valor": Valor,
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> Movim_EliminarDocAbono (var Observacion, var Valor, var Nombre) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(datos.docUsuario).collection("Movimientos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == Nombre) {
            await FirebaseFirestore.instance
                .collection("Usuarios").doc(datos.docUsuario).collection("Movimientos")
                .doc(cursor.id).collection("Deudas").doc()
                .set({
              "FechaMovimiento": now,
              "Descripcion": "Eliminacion de Abono",
              "Nombre": "",
              "Telefono": "",
              "Notas": "",
              "DeudaTotal": "",
              "AbonoTotal": "",
              "Observacion": Observacion,
              "Valor": Valor,
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }
}