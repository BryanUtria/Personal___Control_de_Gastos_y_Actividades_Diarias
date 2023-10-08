import 'package:app_a/1_actualizarDatos.dart';
import 'package:app_a/2_transferenciaDeDatos.dart';
import 'package:app_a/main.dart';
import 'package:app_a/principal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:math' as math;

class prestamos extends StatefulWidget {
  final transferencia_de_Datos datos;
  const prestamos(this.datos, {Key? key}) : super(key: key);

  @override
  prestamos_App createState() => prestamos_App();
}

class prestamos_App extends State<prestamos> {
  final firebase = FirebaseFirestore.instance;
  TextEditingController nombre = TextEditingController();
  TextEditingController telefono = TextEditingController();
  TextEditingController notas = TextEditingController();
  TextEditingController valor = TextEditingController();
  TextEditingController observacion = TextEditingController();
  String IdCliente = "";
  String now = DateFormat.yMMMEd().format(DateTime.now())+", "+DateFormat.jm().format(DateTime.now());
  var FormatoCelular = new MaskTextInputFormatter(
    mask: '(###) ###-##-##',
    filter: { "#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );
  final CurrencyTextInputFormatter FormatoDinero = CurrencyTextInputFormatter(locale: 'ko', decimalDigits: 0, symbol: '\$ ');

  //Cliente

  RegistroClientesDeudas() async {
    try {
      if (nombre.text != "") {
        await firebase
            .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas")
            .doc()
            .set({
          "Nombre": nombre.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
          "Telefono": telefono.text,
          "Notas": notas.text,
          "DeudaTotal": 0.toString(),
          "AbonoTotal": 0.toString(),
          "FechaRegistro" : now,
        });
        actualizarDatos(widget.datos).Movim_RegistroClientesDeudas(nombre.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "), telefono.text, notas.text);
        nombre.clear();
        telefono.clear();
        notas.clear();
      }
      else {
        mensaje("Error", "Registro incorrecto, datos incompletos");
      }
    } catch (e) {
      print(e);
    }
  }

  ActualizarDatosDeudas() async{

    try{
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot usuario = await ref.get();

      if(usuario.docs.length != 0){
        if (nombre.text != "") {
          for(var cursor in usuario.docs){
            if(widget.datos.Deudas_docCliente == cursor.id) {
              await firebase
                  .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas")
                  .doc(cursor.id)
                  .set({
                "Nombre": nombre.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
                "Telefono": telefono.text,
                "Notas": notas.text,
                "DeudaTotal": cursor.get("DeudaTotal"),
                "AbonoTotal": cursor.get("AbonoTotal"),
                "FechaRegistro" : cursor.get("FechaRegistro"),
              });
              actualizarDatos(widget.datos).Movim_ActualizarDatosDeudas(nombre.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "), telefono.text, notas.text);
              BuscarDocClienteDeudas(cursor.id, context);
            }
          }
        }
        else {
          mensaje("Error", "Registro incorrecto, datos incompletos");
        }
      }
      else{
        mensaje("Error", "Coleccion Vacia");
      }
    }catch(e){
      print(e);
    }
  }

  BuscarDocClienteDeudas(String IdCliente, context) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.id == IdCliente) {
            widget.datos.Deudas_AbonoTotal = cursor.get("AbonoTotal");
            widget.datos.Deudas_DeudaTotal = cursor.get("DeudaTotal");
            widget.datos.Deudas_FechaRegistroCliente = cursor.get("FechaRegistro");
            nombre.text = widget.datos.Deudas_NombreCliente = cursor.get("Nombre");
            notas.text = widget.datos.Deudas_NotasCliente = cursor.get("Notas");
            telefono.text = widget.datos.Deudas_TelefonoCliente = cursor.get("Telefono");
            widget.datos.Deudas_docCliente = cursor.id;
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  EliminarDocClienteDeudas() async {
    try {
      CollectionReference ref3=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot usuario = await ref3.get();

      if(usuario.docs.length != 0){
        for(var cursor in usuario.docs){
          if(widget.datos.Deudas_docCliente == cursor.id) {
            actualizarDatos(widget.datos).Movim_EliminarDocClienteDeudas(cursor.get("Nombre"), cursor.get("Telefono"), cursor.get("Notas"), cursor.get("DeudaTotal"), cursor.get("AbonoTotal"));
          }
        }
      }
      else{
        mensaje("Error", "Coleccion Vacia");
      }

      FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).delete()
          .then((doc) => print("Document deleted"), onError: (e) => print("Error updating document $e"),
      );

      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Deudas");
      QuerySnapshot Deuda = await ref.get();

      if(Deuda.docs.length != 0){
        for(var cursor in Deuda.docs){
          FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Deudas").doc(cursor.id).delete()
              .then((doc) => print("Document deleted"), onError: (e) => print("Error updating document $e"),
          );
        }
      }

      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Abonos");
      QuerySnapshot abono = await ref2.get();

      if(abono.docs.length != 0){
        for(var cursor in abono.docs){
          FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Abonos").doc(cursor.id).delete()
              .then((doc) => print("Document deleted"), onError: (e) => print("Error updating document $e"),
          );
        }
      }

      ValorDeudasRestantes();
    } catch (e) {
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
      Navigator.push(context, MaterialPageRoute(builder: (context) => principal(widget.datos)));

    }catch(e){
      print(e);
    }
  }

  //Deudas

  RegistroDeuda() async {
    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == widget.datos.Deudas_NombreCliente) {
            if(observacion.text != "" && valor.text != ""){
              await firebase
                  .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Deudas")
                  .doc()
                  .set({
                "Observacion": observacion.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
                "Valor": valor.text.replaceAll(",", "").replaceAll("\$ ", ""),
                "Fecha" : now,
              });
              actualizarDatos(widget.datos).Movim_RegistroDeuda(observacion.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "), valor.text.replaceAll(",", "").replaceAll("\$ ", ""), widget.datos.Deudas_NombreCliente);
              RecargarValorDeudas(widget.datos.Deudas_docCliente);
              observacion.clear();
              valor.clear();
            }
            else{
              mensaje("Error", "Registro incorrecto, datos incompletos");
            }
          }
        }
      }
    }catch(e){
      print(e);
    }
  }

  RecargarValorDeudas(String IdCliente) async {

    String Valores = "";
    int SumaTotalDeuda = 0;

    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(IdCliente).collection("Deudas");
      QuerySnapshot deudas = await ref.get();

      for(var cursor in deudas.docs){
        Valores = cursor.get("Valor");
        SumaTotalDeuda += int.parse(Valores);
      }

      SumaTotalDeuda = int.parse(SumaTotalDeuda.toString().replaceAll(".0", ""));

      CollectionReference ref2=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot usuario = await ref2.get();

      for(var cursor in usuario.docs){
        if(IdCliente == cursor.id) {
          await firebase
              .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas")
              .doc(cursor.id)
              .set({
            "DeudaTotal": SumaTotalDeuda.toString(),
            "AbonoTotal": cursor.get("AbonoTotal"),
            "Nombre": cursor.get("Nombre"),
            "Telefono": cursor.get("Telefono"),
            "Notas": cursor.get("Notas"),
            "FechaRegistro" : cursor.get("FechaRegistro"),
          });
          setState((){
            BuscarDocClienteDeudas(IdCliente, context);
            ValorDeudasRestantes();
          });
        }
      }

    }catch(e){
      print(e);
    }
  }

  EliminarDocDeuda(String IdDeuda) async {

    try {
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot usuario = await ref.get();
      CollectionReference ref2=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Deudas");
      QuerySnapshot usuario2 = await ref2.get();

      if(usuario.docs.length != 0){
        for(var cursor in usuario.docs){
          if(widget.datos.Deudas_NombreCliente == cursor.get("Nombre")) {
            for(var cursor2 in usuario2.docs){
              if(cursor2.id == IdDeuda){
                actualizarDatos(widget.datos).Movim_EliminarDocDeuda(cursor2.get("Observacion"), cursor2.get("Valor"), widget.datos.Deudas_NombreCliente);
              }
            }
          }
        }
      }
      else{
        mensaje("Error", "Coleccion Vacia");
      }

      FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Deudas").doc(IdDeuda).delete()
          .then((doc) => print("Document deleted"), onError: (e) => print("Error updating document $e"),
      );
      RecargarValorDeudas(widget.datos.Deudas_docCliente);
    } catch (e) {
      print(e);
    }
  }

  BuscarDocDeuda(String IdDeuda) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Deudas");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.id == IdDeuda) {
            observacion.text = cursor.get("Observacion");
            valor.text = cursor.get("Valor");
            widget.datos.docDeuda = cursor.id;
            valor.text = NumberFormat.simpleCurrency(name: '\$ ', decimalDigits: 0).format(int.parse(valor.text));
          }
        }
      }

    } catch (e) {
      print(e);
    }
  }

  ActualizarDatosDeuda() async{

    try{
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Deudas");
      QuerySnapshot Deuda = await ref.get();

      if(Deuda.docs.length != 0){
        if (observacion.text != "" || valor.text != "") {
          for(var cursor in Deuda.docs){
            if(widget.datos.docDeuda == cursor.id) {
              await firebase
                  .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Deudas")
                  .doc(cursor.id)
                  .set({
                "Observacion": observacion.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
                "Valor": valor.text.replaceAll(",", "").replaceAll("\$ ", ""),
                "Fecha" : cursor.get("Fecha"),
              });
              actualizarDatos(widget.datos).Movim_ActualizarDatosDeuda(observacion.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "), valor.text.replaceAll(",", "").replaceAll("\$ ", ""), widget.datos.Deudas_NombreCliente);
              RecargarValorDeudas(widget.datos.Deudas_docCliente);
              observacion.text = "";
              valor.text = "";
            }
          }
        }
        else {
          mensaje("Error", "Registro incorrecto, datos incompletos");
        }
      }
      else{
        mensaje("Error", "Coleccion Vacia");
      }
    }catch(e){
      print(e);
    }
  }

  //Abonos

  ActualizarDatosAbono() async{

    try{
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Abonos");
      QuerySnapshot Deuda = await ref.get();

      if(Deuda.docs.length != 0){
        if (observacion.text != "" || valor.text != "") {
          for(var cursor in Deuda.docs){
            if(widget.datos.docDeuda == cursor.id) {
              await firebase
                  .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Abonos")
                  .doc(cursor.id)
                  .set({
                "Observacion": observacion.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
                "Valor": valor.text.replaceAll(",", "").replaceAll("\$ ", ""),
                "Fecha" : cursor.get("Fecha"),
              });
              actualizarDatos(widget.datos).Movim_ActualizarDatosAbono(observacion.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "), valor.text.replaceAll(",", "").replaceAll("\$ ", ""), widget.datos.Deudas_NombreCliente);
              RecargarValorAbonos(widget.datos.Deudas_docCliente);
              observacion.text = "";
              valor.text = "";
            }
          }
        }
        else {
          mensaje("Error", "Registro incorrecto, datos incompletos");
        }
      }
      else{
        mensaje("Error", "Coleccion Vacia");
      }
    }catch(e){
      print(e);
    }
  }

  RecargarValorAbonos(String IdCliente) async {

    String Valores = "";
    int SumaTotalAbono = 0;

    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(IdCliente).collection("Abonos");
      QuerySnapshot deudas = await ref.get();

      for(var cursor in deudas.docs){
        Valores = cursor.get("Valor");
        SumaTotalAbono += int.parse(Valores);
      }

      SumaTotalAbono = int.parse(SumaTotalAbono.toString().replaceAll(".0", ""));

      CollectionReference ref2=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot usuario = await ref2.get();

      for(var cursor in usuario.docs){
        if(IdCliente == cursor.id) {
          await firebase
              .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas")
              .doc(cursor.id)
              .set({
            "AbonoTotal": SumaTotalAbono.toString(),
            "DeudaTotal": cursor.get("DeudaTotal"),
            "Nombre": cursor.get("Nombre"),
            "Telefono": cursor.get("Telefono"),
            "Notas": cursor.get("Notas"),
            "FechaRegistro" : cursor.get("FechaRegistro"),
          });
          setState((){
            BuscarDocClienteDeudas(IdCliente,context);
            ValorDeudasRestantes();
          });
        }
      }

    }catch(e){
      print(e);
    }
  }

  BuscarDocAbono(String IdDeuda) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Abonos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.id == IdDeuda) {
            observacion.text = cursor.get("Observacion");
            valor.text = cursor.get("Valor");
            widget.datos.docDeuda = cursor.id;
            valor.text = NumberFormat.simpleCurrency(name: '\$ ', decimalDigits: 0).format(int.parse(valor.text));
          }
        }
      }

    } catch (e) {
      print(e);
    }
  }

  EliminarDocAbono(String IdDeuda) async {

    try {
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot usuario = await ref.get();
      CollectionReference ref2=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Abonos");
      QuerySnapshot usuario2 = await ref2.get();

      if(usuario.docs.length != 0){
        for(var cursor in usuario.docs){
          if(widget.datos.Deudas_NombreCliente == cursor.get("Nombre")) {
            for(var cursor2 in usuario2.docs){
              if(cursor2.id == IdDeuda){
                actualizarDatos(widget.datos).Movim_EliminarDocAbono(cursor2.get("Observacion"), cursor2.get("Valor"), widget.datos.Deudas_NombreCliente);
              }
            }
          }
        }
      }
      else{
        mensaje("Error", "Coleccion Vacia");
      }

      FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Abonos").doc(IdDeuda).delete()
          .then((doc) => print("Document deleted"), onError: (e) => print("Error updating document $e"),
      );
      RecargarValorAbonos(widget.datos.Deudas_docCliente);
    } catch (e) {
      print(e);
    }
  }

  RegistroAbonoDeuda() async {
    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.get("Nombre") == widget.datos.Deudas_NombreCliente) {
            if(observacion.text != "" && valor.text != ""){
              await firebase
                  .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").doc(widget.datos.Deudas_docCliente).collection("Abonos")
                  .doc()
                  .set({
                "Observacion": observacion.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
                "Valor": valor.text.replaceAll(",", "").replaceAll("\$ ", ""),
                "Fecha" : now,
              });
              actualizarDatos(widget.datos).Movim_RegistroAbonoDeuda(observacion.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "), valor.text.replaceAll(",", "").replaceAll("\$ ", ""), widget.datos.Deudas_NombreCliente);
              RecargarValorAbonos(widget.datos.Deudas_docCliente);
              observacion.clear();
              valor.clear();
            }
            else{
              mensaje("Error", "Registro incorrecto, datos incompletos");
            }
          }
        }
      }
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Color(0xFF95E5E2),
        body: Container(
            child: Center(
                child: Column(
                  children: [
                    //Valor Deudas Restante
                    Padding(padding: EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.green,
                                              width: 10,
                                            ),
                                          ),
                                          child: Text("Valor Total Deudas Restante: ${NumberFormat.simpleCurrency(name: '\$ ', decimalDigits: 0).format(int.parse(widget.datos.ValorDeudaRestante))}", style: TextStyle(fontSize: SubTitulo, color: Colors.white)),
                                        )
                                    )
                                  ]
                              ),
                            ]
                        )
                    ),
                    //Detalle Deudas
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudas").orderBy("Nombre", descending: false).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) return CircularProgressIndicator();
                          return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    margin: EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 5),
                                    elevation: 3,
                                    child:  Row(
                                        children: [
                                          //Tarjeta Boton Deudas y Boton Abonos
                                          Expanded(
                                            child: MaterialButton(
                                              child: Column(
                                                  children: <Widget>[
                                                    ListTile(contentPadding: EdgeInsets.fromLTRB(3, 6, 3, 6),
                                                      title: Text('${snapshot.data!.docs[index].get("Nombre")}', style: TextStyle(fontSize: SubTitulo)),
                                                      subtitle: Text('Deuda Total: ${NumberFormat.simpleCurrency(name: '\$ ', decimalDigits: 0).format(int.parse(snapshot.data!.docs[index].get("DeudaTotal")))}\n'
                                                          'Abono Total: ${NumberFormat.simpleCurrency(name: '\$ ', decimalDigits: 0).format(int.parse(snapshot.data!.docs[index].get("AbonoTotal")))}\n'
                                                          'Deuda Restante: ${NumberFormat.simpleCurrency(name: '\$ ', decimalDigits: 0).format(int.parse(snapshot.data!.docs[index].get("DeudaTotal"))-int.parse(snapshot.data!.docs[index].get("AbonoTotal")))}',
                                                          style: TextStyle(fontSize: Cuerpo)),
                                                      leading: CircleAvatar(
                                                        backgroundColor: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1),
                                                        child: Text(snapshot.data!.docs[index].get("Nombre").substring(0, 1)),
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                              onPressed: () {
                                                BuscarDocClienteDeudas(snapshot.data!.docs[index].id, context);
                                                showDialog<String>(
                                                  context: context,
                                                  builder: (BuildContext context) =>
                                                      AlertDialog(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                        titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                        title: Text('Que Desea Realizar',style: TextStyle(fontSize: VentanaTitulo), textAlign: TextAlign.center),
                                                        actions: <Widget>[
                                                          Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                                              child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: [
                                                                    //Boton Deudas
                                                                    MaterialButton(
                                                                      minWidth: 250.0,
                                                                      height: 40.0,
                                                                      color: Colors.blue,
                                                                      onPressed: () {
                                                                        showDialog<String>(
                                                                          context: context,
                                                                          builder: (BuildContext context) =>
                                                                              AlertDialog(
                                                                                backgroundColor: Colors.grey[300],
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 0),
                                                                                title: Text('Deudas', style: TextStyle(fontSize: VentanaTitulo), textAlign: TextAlign.center),
                                                                                actions: <Widget>[
                                                                                  Padding(padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                                                                                      child: Column(
                                                                                        children: [
                                                                                          //Valor Deudas Restante
                                                                                          Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Padding(padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
                                                                                                  child: Container(
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: Colors.green,
                                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                                        border: Border.all(
                                                                                                          color: Colors.green,
                                                                                                          width: 10,
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: Text("Valor Total Deudas: ${NumberFormat.simpleCurrency(name: '\$ ', decimalDigits: 0).format(int.parse(widget.datos.Deudas_DeudaTotal))}", style: TextStyle(fontSize: VentanaSubTitulo, color: Colors.white))
                                                                                                  ),
                                                                                                )
                                                                                              ]
                                                                                          ),
                                                                                          //Detalle Deudas
                                                                                          StreamBuilder(
                                                                                              stream: FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection('UsuariosDeudas').doc(widget.datos.Deudas_docCliente).collection('Deudas').snapshots(),
                                                                                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                                                                if (!snapshot.hasData){
                                                                                                  return CircularProgressIndicator();
                                                                                                }
                                                                                                return Container(
                                                                                                  height: 300,
                                                                                                  width: 300,
                                                                                                  child: ListView.builder(
                                                                                                      scrollDirection: Axis.vertical,
                                                                                                      shrinkWrap: true,
                                                                                                      itemCount: snapshot.data!.docs.length,
                                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                                        return Card(
                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                                            margin: EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 5),
                                                                                                            elevation: 3,
                                                                                                            child: Row(
                                                                                                                children: [
                                                                                                                  //Tarjetas deudas y editar deudas
                                                                                                                  Expanded(
                                                                                                                    child: MaterialButton(
                                                                                                                      child: Column(
                                                                                                                          children: <Widget>[
                                                                                                                            ListTile(
                                                                                                                              contentPadding: EdgeInsets.all(2),
                                                                                                                              title: Text(snapshot.data!.docs[index].get("Observacion"), style: TextStyle(fontSize: VentanaSubTitulo)),
                                                                                                                              subtitle: Text('Valor: ${NumberFormat.simpleCurrency(name: '\$ ', decimalDigits: 0).format(int.parse(snapshot.data!.docs[index].get("Valor")))}\n${snapshot.data!.docs[index].get("Fecha")}', style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                                                            ),
                                                                                                                          ]
                                                                                                                      ),
                                                                                                                      onPressed: () {
                                                                                                                        BuscarDocDeuda(snapshot.data!.docs[index].id);
                                                                                                                        showDialog<String>(
                                                                                                                          context: context,
                                                                                                                          builder: (BuildContext context) =>
                                                                                                                              AlertDialog(
                                                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                                                                titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                                                                                                title: Text('Actualizar Deuda', style: TextStyle(fontSize: VentanaTitulo), textAlign: TextAlign.center),
                                                                                                                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                                                                                content: Text('A continuacion modifique los datos de la deuda', style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                                                                actions: <Widget>[
                                                                                                                                  //Nombre de la deuda
                                                                                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                                                                                                                                    child: TextField(
                                                                                                                                      controller: observacion,
                                                                                                                                      textCapitalization: TextCapitalization.words,
                                                                                                                                      decoration: InputDecoration(
                                                                                                                                          labelText: "Observacion de la deuda",
                                                                                                                                          labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                                          hintText: "Digite la observacion de la deuda",
                                                                                                                                          hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                                          border: OutlineInputBorder(
                                                                                                                                            borderRadius: BorderRadius.circular(15),
                                                                                                                                          )
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                  ),
                                                                                                                                  //Valor de la deuda
                                                                                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                                                                                                                                    child: TextField(
                                                                                                                                      keyboardType: TextInputType.phone,
                                                                                                                                      inputFormatters: [FormatoDinero],
                                                                                                                                      controller: valor,
                                                                                                                                      decoration: InputDecoration(
                                                                                                                                          labelText: "Valor de la deuda",
                                                                                                                                          labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                                          hintText: "Digite el valor de la deuda",
                                                                                                                                          hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                                          border: OutlineInputBorder(
                                                                                                                                            borderRadius: BorderRadius.circular(15),
                                                                                                                                          )
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                  ),
                                                                                                                                  //Botones Agregar y Cancelar
                                                                                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 10),
                                                                                                                                    child: Row(
                                                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                                        children: [
                                                                                                                                          MaterialButton(
                                                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                            color: Colors.blue,
                                                                                                                                            onPressed: () {
                                                                                                                                              ActualizarDatosDeuda();
                                                                                                                                              Navigator.pop(context, 'Actualizar');
                                                                                                                                              Navigator.pop(context, 'Detalle Deuda');
                                                                                                                                              Navigator.pop(context, 'Deuda');
                                                                                                                                            },
                                                                                                                                            child: Text('Actualizar',
                                                                                                                                              style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                                                            ),
                                                                                                                                          ),

                                                                                                                                          MaterialButton(
                                                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                            color: Colors.red,
                                                                                                                                            onPressed: () {
                                                                                                                                              Navigator.pop(context, 'Cancelar');
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
                                                                                                                        );
                                                                                                                      },
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  //Eliminar deudas
                                                                                                                  Container(
                                                                                                                    child: MaterialButton(
                                                                                                                      child: Row(
                                                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                        children: [
                                                                                                                          Icon(Icons.delete, color: Colors.black),
                                                                                                                        ],
                                                                                                                      ),
                                                                                                                      onPressed: () {
                                                                                                                        showDialog<String>(
                                                                                                                          context: context,
                                                                                                                          builder: (BuildContext context) =>
                                                                                                                              AlertDialog(
                                                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                                                                titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                                                                                                title: Text('Eliminar Deuda', style: TextStyle(fontSize: VentanaTitulo), textAlign: TextAlign.center),
                                                                                                                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                                                                                content: Text('¿Seguro quiere eliminar la deuda?', style: TextStyle(fontSize: VentanaCuerpo), textAlign: TextAlign.center),
                                                                                                                                actions: <Widget>[
                                                                                                                                  //Aceptar y Cancelar
                                                                                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                                                                                                                    child: Row(
                                                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                                        children: [
                                                                                                                                          MaterialButton(
                                                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                            color: Colors.blue,
                                                                                                                                            onPressed: () {
                                                                                                                                              EliminarDocDeuda(snapshot.data!.docs[index].id);
                                                                                                                                              Navigator.pop(context, 'Aceptar');
                                                                                                                                              Navigator.pop(context, 'Detalle Deuda');
                                                                                                                                              Navigator.pop(context, 'Deuda');
                                                                                                                                            },
                                                                                                                                            child: Text('Aceptar',
                                                                                                                                              style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                                                            ),
                                                                                                                                          ),

                                                                                                                                          MaterialButton(
                                                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                            color: Colors.red,
                                                                                                                                            onPressed: () {
                                                                                                                                              Navigator.pop(context, 'Cancelar');
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
                                                                                                                        );
                                                                                                                      },
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ]
                                                                                                            )
                                                                                                        );
                                                                                                      }
                                                                                                  ),
                                                                                                );
                                                                                              }
                                                                                          ),
                                                                                          //Boton Agregar y Cancelar
                                                                                          Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                              children: [
                                                                                                MaterialButton(
                                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                  color: Colors.blue,
                                                                                                  onPressed: () {
                                                                                                    showDialog<String>(
                                                                                                      context: context,
                                                                                                      builder: (BuildContext context) =>
                                                                                                          AlertDialog(
                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                                            titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                                                                            title: Text('Agregar Deuda', style: TextStyle(fontSize: VentanaTitulo)),
                                                                                                            contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                                                            content:  Text('A continuacion ingrese la deuda', style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                                            actions: <Widget>[
                                                                                                              Padding(padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                                                                                                                  child: Column(
                                                                                                                    children: [
                                                                                                                      //Notas de la deuda
                                                                                                                      Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                                                                                                                        child: TextField(
                                                                                                                          controller: observacion,
                                                                                                                          textCapitalization: TextCapitalization.words,
                                                                                                                          decoration: InputDecoration(
                                                                                                                              labelText: "Observacion de la deuda",
                                                                                                                              labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                              hintText: "Digite la observacion de la deuda",
                                                                                                                              hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                              border: OutlineInputBorder(
                                                                                                                                borderRadius: BorderRadius.circular(15),
                                                                                                                              )
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      //Valor de la deuda
                                                                                                                      Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
                                                                                                                        child: TextField(
                                                                                                                          keyboardType: TextInputType.phone,
                                                                                                                          inputFormatters: [FormatoDinero],
                                                                                                                          controller: valor,
                                                                                                                          decoration: InputDecoration(
                                                                                                                              labelText: "Valor",
                                                                                                                              labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                              hintText: "Digite el valor de la deuda",
                                                                                                                              hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                              border: OutlineInputBorder(
                                                                                                                                borderRadius: BorderRadius.circular(15),
                                                                                                                              )
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      //Boton Aceptar y Cancelar
                                                                                                                      Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                                                                                                        child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                            children: [
                                                                                                                              MaterialButton(
                                                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                color: Colors.blue,
                                                                                                                                onPressed: () {
                                                                                                                                  RegistroDeuda();
                                                                                                                                  Navigator.pop(context, 'Aceptar');
                                                                                                                                  Navigator.pop(context, 'Detalle Deuda');
                                                                                                                                  Navigator.pop(context, 'Deuda');
                                                                                                                                },
                                                                                                                                child: Text('Aceptar',
                                                                                                                                  style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                                                ),
                                                                                                                              ),

                                                                                                                              MaterialButton(
                                                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                color: Colors.red,
                                                                                                                                onPressed: () {
                                                                                                                                  Navigator.pop(context, 'Cancelar');
                                                                                                                                  observacion.clear();
                                                                                                                                  valor.clear();
                                                                                                                                },
                                                                                                                                child: Text('Cancelar',
                                                                                                                                  style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ]
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  )
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                    );
                                                                                                  },
                                                                                                  child: Text('Agregar',
                                                                                                    style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                  ),
                                                                                                ),

                                                                                                MaterialButton(
                                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                  color: Colors.red,
                                                                                                  onPressed: () => Navigator.pop(context, 'Cancelar'),
                                                                                                  child: Text('Cancelar',
                                                                                                    style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                        );
                                                                      },
                                                                      child: Text('Deudas',
                                                                        style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                      ),
                                                                    ),
                                                                    //Boton Abonos
                                                                    MaterialButton(
                                                                      minWidth: 250.0,
                                                                      height: 40.0,
                                                                      color: Colors.red,
                                                                      onPressed: () {
                                                                        showDialog<String>(
                                                                          context: context,
                                                                          builder: (BuildContext context) =>
                                                                              AlertDialog(
                                                                                backgroundColor: Colors.grey[300],
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 0),
                                                                                title: Text('Abonos', style: TextStyle(fontSize: VentanaTitulo), textAlign: TextAlign.center),
                                                                                actions: <Widget>[
                                                                                  Padding(padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                                                                                      child: Column(
                                                                                        children: [
                                                                                          //Valor Abonos Restante
                                                                                          Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Padding(padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
                                                                                                  child: Container(
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: Colors.green,
                                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                                        border: Border.all(
                                                                                                          color: Colors.green,
                                                                                                          width: 10,
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: Text("Valor Total Abonos: ${NumberFormat.simpleCurrency(name: '\$ ', decimalDigits: 0).format(int.parse(widget.datos.Deudas_AbonoTotal))}", style: TextStyle(fontSize: VentanaSubTitulo, color: Colors.white))
                                                                                                  ),
                                                                                                )
                                                                                              ]
                                                                                          ),
                                                                                          //Detalle abonos
                                                                                          StreamBuilder(
                                                                                              stream: FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection('UsuariosDeudas').doc(widget.datos.Deudas_docCliente).collection('Abonos').snapshots(),
                                                                                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                                                                if (!snapshot.hasData){
                                                                                                  return CircularProgressIndicator();
                                                                                                }
                                                                                                return Container(
                                                                                                  height: 300,
                                                                                                  width: 300,
                                                                                                  child: ListView.builder(
                                                                                                      scrollDirection: Axis.vertical,
                                                                                                      shrinkWrap: true,
                                                                                                      itemCount: snapshot.data!.docs.length,
                                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                                        return Card(
                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                                            margin: EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 5),
                                                                                                            elevation: 3,
                                                                                                            child: Row(
                                                                                                                children: [
                                                                                                                  //Tarjetas abonos y editar abonos
                                                                                                                  Expanded(
                                                                                                                    child: MaterialButton(
                                                                                                                      child: Column(
                                                                                                                          children: <Widget>[
                                                                                                                            ListTile(
                                                                                                                              contentPadding: EdgeInsets.all(2),
                                                                                                                              title: Text(snapshot.data!.docs[index].get("Observacion"), style: TextStyle(fontSize: VentanaSubTitulo)),
                                                                                                                              subtitle: Text('Valor: ${NumberFormat.simpleCurrency(name: '\$ ', decimalDigits: 0).format(int.parse(snapshot.data!.docs[index].get("Valor")))}\n${snapshot.data!.docs[index].get("Fecha")}', style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                                                            ),
                                                                                                                          ]
                                                                                                                      ),
                                                                                                                      onPressed: () {
                                                                                                                        BuscarDocAbono(snapshot.data!.docs[index].id);
                                                                                                                        showDialog<String>(
                                                                                                                          context: context,
                                                                                                                          builder: (BuildContext context) =>
                                                                                                                              AlertDialog(
                                                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                                                                titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                                                                                                title: Text('Actualizar Abono', style: TextStyle(fontSize: VentanaTitulo), textAlign: TextAlign.center),
                                                                                                                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                                                                                content: Text('A continuacion modifique los datos del abono', style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                                                                actions: <Widget>[
                                                                                                                                  //Nombre del abono
                                                                                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                                                                                                                                    child: TextField(
                                                                                                                                      controller: observacion,
                                                                                                                                      textCapitalization: TextCapitalization.words,
                                                                                                                                      decoration: InputDecoration(
                                                                                                                                          labelText: "Observacion del abono",
                                                                                                                                          labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                                          hintText: "Digite la observacion del abono",
                                                                                                                                          hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                                          border: OutlineInputBorder(
                                                                                                                                            borderRadius: BorderRadius.circular(15),
                                                                                                                                          )
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                  ),
                                                                                                                                  //Valor del abono
                                                                                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                                                                                                                                    child: TextField(
                                                                                                                                      keyboardType: TextInputType.phone,
                                                                                                                                      inputFormatters: [FormatoDinero],
                                                                                                                                      controller: valor,
                                                                                                                                      decoration: InputDecoration(
                                                                                                                                          labelText: "Valor del abono",
                                                                                                                                          labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                                          hintText: "Digite el valor del abono",
                                                                                                                                          hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                                          border: OutlineInputBorder(
                                                                                                                                            borderRadius: BorderRadius.circular(15),
                                                                                                                                          )
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                  ),
                                                                                                                                  //Botones actualizar y Cancelar
                                                                                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 10),
                                                                                                                                    child: Row(
                                                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                                        children: [
                                                                                                                                          MaterialButton(
                                                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                            color: Colors.blue,
                                                                                                                                            onPressed: () {
                                                                                                                                              ActualizarDatosAbono();
                                                                                                                                              Navigator.pop(context, 'Actualizar');
                                                                                                                                              Navigator.pop(context, 'Detalle Abono');
                                                                                                                                              Navigator.pop(context, 'Abono');
                                                                                                                                            },
                                                                                                                                            child: Text('Actualizar',
                                                                                                                                              style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                                                            ),
                                                                                                                                          ),

                                                                                                                                          MaterialButton(
                                                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                            color: Colors.red,
                                                                                                                                            onPressed: () {
                                                                                                                                              Navigator.pop(context, 'Cancelar');
                                                                                                                                              observacion.text = "";
                                                                                                                                              valor.text = "";
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
                                                                                                                        );
                                                                                                                      },
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  //Eliminar abonos
                                                                                                                  Container(
                                                                                                                    child: MaterialButton(
                                                                                                                      child: Row(
                                                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                        children: [
                                                                                                                          Icon(Icons.delete, color: Colors.black),
                                                                                                                        ],
                                                                                                                      ),
                                                                                                                      onPressed: () {
                                                                                                                        showDialog<String>(
                                                                                                                          context: context,
                                                                                                                          builder: (BuildContext context) =>
                                                                                                                              AlertDialog(
                                                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                                                                titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                                                                                                title: Text('Eliminar Abonos', style: TextStyle(fontSize: VentanaTitulo), textAlign: TextAlign.center),
                                                                                                                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                                                                                content: Text('¿Seguro quiere eliminar el abono?', style: TextStyle(fontSize: VentanaCuerpo), textAlign: TextAlign.center),
                                                                                                                                actions: <Widget>[
                                                                                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                                                                                                                    child: Row(
                                                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                                        children: [
                                                                                                                                          MaterialButton(
                                                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                            color: Colors.blue,
                                                                                                                                            onPressed: () {
                                                                                                                                              EliminarDocAbono(snapshot.data!.docs[index].id);
                                                                                                                                              Navigator.pop(context, 'Aceptar');
                                                                                                                                              Navigator.pop(context, 'Detalle Abono');
                                                                                                                                              Navigator.pop(context, 'Abono');
                                                                                                                                            },
                                                                                                                                            child: Text('Aceptar',
                                                                                                                                              style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                                                            ),
                                                                                                                                          ),

                                                                                                                                          MaterialButton(
                                                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                            color: Colors.red,
                                                                                                                                            onPressed: () {
                                                                                                                                              Navigator.pop(context, 'Cancelar');
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
                                                                                                                        );
                                                                                                                      },
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ]
                                                                                                            )
                                                                                                        );
                                                                                                      }
                                                                                                  ),
                                                                                                );
                                                                                              }
                                                                                          ),
                                                                                          //Boton Agregar y Cancelar
                                                                                          Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                              children: [
                                                                                                MaterialButton(
                                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                  color: Colors.blue,
                                                                                                  onPressed: () {
                                                                                                    showDialog<String>(
                                                                                                      context: context,
                                                                                                      builder: (BuildContext context) =>
                                                                                                          AlertDialog(
                                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                                            titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                                                                            title: Text('Agregar Abono', style: TextStyle(fontSize: VentanaTitulo)),
                                                                                                            contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                                                            content: Text('A continuacion ingrese el abono:', style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                                            actions: <Widget>[
                                                                                                              Padding(padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                                                                                                                  child: Column(
                                                                                                                    children: [
                                                                                                                      //Notas del abono
                                                                                                                      Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                                                                                                                        child: TextField(
                                                                                                                          controller: observacion,
                                                                                                                          textCapitalization: TextCapitalization.words,
                                                                                                                          decoration: InputDecoration(
                                                                                                                              labelText: "Observacion del abono",
                                                                                                                              labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                              hintText: "Digite la observacion del abono",
                                                                                                                              hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                              border: OutlineInputBorder(
                                                                                                                                borderRadius: BorderRadius.circular(15),
                                                                                                                              )
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      //Valor del abono
                                                                                                                      Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
                                                                                                                        child: TextField(
                                                                                                                          keyboardType: TextInputType.phone,
                                                                                                                          inputFormatters: [FormatoDinero],
                                                                                                                          controller: valor,
                                                                                                                          decoration: InputDecoration(
                                                                                                                              labelText: "Valor",
                                                                                                                              labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                              hintText: "Digite el valor del abono",
                                                                                                                              hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                                              border: OutlineInputBorder(
                                                                                                                                borderRadius: BorderRadius.circular(15),
                                                                                                                              )
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      //Boton Aceptar y Cancelar
                                                                                                                      Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                                                                                                        child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                            children: [
                                                                                                                              MaterialButton(
                                                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                color: Colors.blue,
                                                                                                                                onPressed: () {
                                                                                                                                  RegistroAbonoDeuda();
                                                                                                                                  Navigator.pop(context, 'Aceptar');
                                                                                                                                  Navigator.pop(context, 'Detalle Abono');
                                                                                                                                  Navigator.pop(context, 'Abono');
                                                                                                                                },
                                                                                                                                child: Text('Aceptar',
                                                                                                                                  style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                                                ),
                                                                                                                              ),

                                                                                                                              MaterialButton(
                                                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                                                color: Colors.red,
                                                                                                                                onPressed: () {
                                                                                                                                  Navigator.pop(context, 'Cancelar');
                                                                                                                                  observacion.clear();
                                                                                                                                  valor.clear();
                                                                                                                                },
                                                                                                                                child: Text('Cancelar',
                                                                                                                                  style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ]
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  )
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                    );
                                                                                                  },
                                                                                                  child: Text('Agregar',
                                                                                                    style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                  ),
                                                                                                ),

                                                                                                MaterialButton(
                                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                  color: Colors.red,
                                                                                                  onPressed: () => Navigator.pop(context, 'Cancelar'),
                                                                                                  child: Text('Cancelar',
                                                                                                    style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                        );
                                                                      },
                                                                      child: Text('Abonos',
                                                                        style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                      ),
                                                                    )
                                                                  ]
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                );
                                              },
                                            ),
                                          ),
                                          //Boton Informacion y eliminar tarjeta
                                          Container(
                                              child: Column(
                                                  children: [
                                                    //Boton Informacion y Editar
                                                    MaterialButton(
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.info, color: Colors.black, size: 27),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        BuscarDocClienteDeudas(snapshot.data!.docs[index].id, context);
                                                        showDialog<String>(
                                                          context: context,
                                                          builder: (BuildContext context) =>
                                                              AlertDialog(
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                                title: Text('Informacion de Cliente', style: TextStyle(fontSize: VentanaTitulo), textAlign: TextAlign.center),
                                                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                content: Text('A continuacion se mostrara la informacion del cliente:', style: TextStyle(fontSize: VentanaCuerpo)),
                                                                actions: <Widget>[
                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                                                      child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: [
                                                                            Padding(padding: EdgeInsets.only(left: 10, top: 0, right: 25, bottom: 0),
                                                                                child: Column(
                                                                                  children: [
                                                                                    //Nombre del cliente
                                                                                    Row(
                                                                                        children: [
                                                                                          Text("Nombre: ${widget.datos.Deudas_NombreCliente}\n", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                        ]
                                                                                    ),
                                                                                    if(widget.datos.Deudas_TelefonoCliente != "")...[
                                                                                      //Telefono del cliente
                                                                                      Row(
                                                                                        children: [
                                                                                          Text("Telefono: ${widget.datos.Deudas_TelefonoCliente}\n", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                    if(widget.datos.Deudas_NotasCliente != "")...[
                                                                                      //Notas del cliente
                                                                                      Row(
                                                                                        children: [
                                                                                          Text("Notas: ${widget.datos.Deudas_NotasCliente}\n", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                    //Fecha Registro del cliente
                                                                                    Row(
                                                                                      children: [
                                                                                        Text("Fecha: ${widget.datos.Deudas_FechaRegistroCliente}\n", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                )
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                //Boton Editar
                                                                                MaterialButton(
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                  color: Colors.blue,
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context, 'Editar');
                                                                                    //Boton Editar
                                                                                    showDialog<String>(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) =>
                                                                                          AlertDialog(
                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                            titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                                                            title: Text('Actualizar Usuario', style: TextStyle(fontSize: VentanaTitulo)),
                                                                                            contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                                            content: Text('A continuacion modifique sus datos', style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                            actions: <Widget>[
                                                                                              //Nombre del cliente
                                                                                              Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                                                                                                child: TextField(
                                                                                                  readOnly: true,
                                                                                                  enabled: false,
                                                                                                  controller: nombre,
                                                                                                  decoration: InputDecoration(
                                                                                                      labelText: "Nombre del cliene",
                                                                                                      labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                      hintText: "Digite el nombre del cliente",
                                                                                                      hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                      border: OutlineInputBorder(
                                                                                                        borderRadius: BorderRadius.circular(15),
                                                                                                      )
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              //Telefono del cliente
                                                                                              Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                                                                                                child: TextField(
                                                                                                  keyboardType: TextInputType.phone,
                                                                                                  inputFormatters: [FormatoCelular],
                                                                                                  controller: telefono,
                                                                                                  decoration: InputDecoration(
                                                                                                      labelText: "Telefono del cliene (Opcional)",
                                                                                                      labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                      hintText: "Digite el telefono del cliente",
                                                                                                      hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                      border: OutlineInputBorder(
                                                                                                        borderRadius: BorderRadius.circular(15),
                                                                                                      )
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              //Notas del cliente
                                                                                              Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
                                                                                                child: TextField(
                                                                                                  controller: notas,
                                                                                                  decoration: InputDecoration(
                                                                                                      labelText: "Notas (Opcional)",
                                                                                                      labelStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                      hintText: "Digite alguna nota del cliente",
                                                                                                      hintStyle: TextStyle(fontSize: VentanaCuerpo),
                                                                                                      border: OutlineInputBorder(
                                                                                                        borderRadius: BorderRadius.circular(15),
                                                                                                      )
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              //Botones Actualizar y Cancelar
                                                                                              Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                  children: [
                                                                                                    MaterialButton(
                                                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                      color: Colors.blue,
                                                                                                      onPressed: () {
                                                                                                        ActualizarDatosDeudas();
                                                                                                        Navigator.pop(context, 'Actualizar');
                                                                                                      },
                                                                                                      child: Text('Actualizar',
                                                                                                        style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                      ),
                                                                                                    ),

                                                                                                    MaterialButton(
                                                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                                      color: Colors.red,
                                                                                                      onPressed: () => Navigator.pop(context, 'Cancelar'),
                                                                                                      child: Text('Cancelar',
                                                                                                        style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                    );
                                                                                  },
                                                                                  child: Text('Editar',
                                                                                    style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                  ),
                                                                                ),
                                                                                //Boton Cancelar
                                                                                MaterialButton(
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                  color: Colors.red,
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context, 'Cancelar');
                                                                                  },
                                                                                  child: Text('Cancelar',
                                                                                    style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ]
                                                                      )
                                                                  ),
                                                                ],
                                                              ),
                                                        );
                                                      },
                                                    ),
                                                    //Boton Eliminar
                                                    MaterialButton(
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.delete, color: Colors.black, size: 27),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        BuscarDocClienteDeudas(snapshot.data!.docs[index].id, context);
                                                        showDialog<String>(
                                                          context: context,
                                                          builder: (BuildContext context) =>
                                                              AlertDialog(
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                                title: Text('Eliminar Usuario', style: TextStyle(fontSize: VentanaTitulo), textAlign: TextAlign.center),
                                                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                content: Text('¿Seguro quiere eliminar el usuario?', style: TextStyle(fontSize: VentanaCuerpo), textAlign: TextAlign.center),
                                                                actions: <Widget>[
                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                                                      child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            MaterialButton(
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                              color: Colors.blue,
                                                                              onPressed: () {
                                                                                EliminarDocClienteDeudas();
                                                                                Navigator.pop(context, 'Aceptar');
                                                                              },
                                                                              child: Text('Aceptar',
                                                                                style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                            MaterialButton(
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                              color: Colors.red,
                                                                              onPressed: () {
                                                                                Navigator.pop(context, 'Cancelar');
                                                                              },
                                                                              child: Text('Cancelar',
                                                                                style: TextStyle(fontSize: Botones, color: Colors.white),
                                                                              ),
                                                                            )
                                                                          ]
                                                                      )
                                                                  ),
                                                                ],
                                                              ),
                                                        );
                                                      },
                                                    ),
                                                  ]
                                              )
                                          ),
                                        ]
                                    )
                                );
                              }
                          );
                        },
                      ),
                    ),
                  ],
                )
            )
        ),
        floatingActionButton:  FloatingActionButton (
          onPressed: () {
            nombre.text = "";
            telefono.text = "";
            notas.text = "";
            showDialog<String>(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                    title: Text('Agregar Cliente', style: TextStyle(fontSize: VentanaTitulo)),
                    contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                    content: Text('A continuacion ingrese los datos del cliente', style: TextStyle(fontSize: VentanaCuerpo)),
                    actions: <Widget>[
                      //Nombre del cliente
                      Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                        child: TextField(
                          controller: nombre,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                              labelText: "Nombre del cliente",
                              labelStyle: TextStyle(fontSize: VentanaCuerpo),
                              hintText: "Digite el nombre del cliente",
                              hintStyle: TextStyle(fontSize: VentanaCuerpo),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              )
                          ),
                        ),
                      ),
                      //Telefono del cliente
                      Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FormatoCelular],
                          controller: telefono,
                          decoration: InputDecoration(
                              labelText: "Telefono del cliente (Opcional)",
                              labelStyle: TextStyle(fontSize: VentanaCuerpo),
                              hintText: "Digite el telefono del cliente",
                              hintStyle: TextStyle(fontSize: VentanaCuerpo),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              )
                          ),
                        ),
                      ),
                      //Notas
                      Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
                        child: TextField(
                          controller: notas,
                          decoration: InputDecoration(
                              labelText: "Notas (Opcional)",
                              labelStyle: TextStyle(fontSize: VentanaCuerpo),
                              hintText: "Digite alguna nota del cliente",
                              hintStyle: TextStyle(fontSize: VentanaCuerpo),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              )
                          ),
                        ),
                      ),
                      //Registrar o Cancelar
                      Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MaterialButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                color: Colors.blue,
                                onPressed: () {
                                  RegistroClientesDeudas();
                                  Navigator.pop(context, 'Registrar');
                                },
                                child: Text('Registrar',
                                  style: TextStyle(fontSize: Botones, color: Colors.white),
                                ),
                              ),

                              MaterialButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                color: Colors.red,
                                onPressed: () {
                                  Navigator.pop(context, 'Cancelar');
                                  nombre.clear();
                                  telefono.clear();
                                  notas.clear();
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
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
          tooltip: 'Agregar Cliente',
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