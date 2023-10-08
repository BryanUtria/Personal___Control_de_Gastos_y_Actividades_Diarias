// ignore_for_file: deprecated_member_use
import 'package:app_a/2_transferenciaDeDatos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Ver_Cliente_Deudor extends StatefulWidget {
  final transferencia_de_Datos datos;
  const Ver_Cliente_Deudor(this.datos, {Key? key}) : super(key: key);

  Ver_Cliente_Deudor_App createState() => Ver_Cliente_Deudor_App();
}

class Ver_Cliente_Deudor_App extends State<Ver_Cliente_Deudor> {
  final firebase = FirebaseFirestore.instance;
  TextEditingController producto = TextEditingController();
  TextEditingController valor = TextEditingController();
  TextEditingController observacion = TextEditingController();
  String now = DateFormat.yMMMEd().format(DateTime.now())+", "+DateFormat.jm().format(DateTime.now());
  final CurrencyTextInputFormatter FormatoDinero = CurrencyTextInputFormatter(locale: 'ko', decimalDigits: 0, symbol: ' ');

  RegistroDeuda() async {
    int banUsuario = 0;

    try{
      if(producto.text != "" && valor.text != ""){
        banUsuario = 1;
        await firebase
            .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Deudas")
            .doc()
            .set({
          "Producto": producto.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
          "Valor": valor.text.replaceAll(",", ""),
          "Fecha" : now,
        });
      }
      else{
        mensaje("Error", "Registro incorrecto, datos incompletos");
      }
    }catch(e){
      print(e);
    }

    if(banUsuario == 1){
      RecargarValorDeudas(widget.datos.Deudas_docCliente);
      producto.clear();
      valor.clear();
    }
  }

  EliminarDocCliente() async {
    try {
      FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).delete()
          .then((doc) => print("Document deleted"), onError: (e) => print("Error updating document $e"),
      );

      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Deudas");
      QuerySnapshot Deuda = await ref.get();

      if(Deuda.docs.length != 0){
        for(var cursor in Deuda.docs){
          FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Deudas").doc(cursor.id).delete()
              .then((doc) => print("Document deleted"), onError: (e) => print("Error updating document $e"),
          );
        }
      }

      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Abonos");
      QuerySnapshot abono = await ref2.get();

      if(abono.docs.length != 0){
        for(var cursor in abono.docs){
          FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Abonos").doc(cursor.id).delete()
              .then((doc) => print("Document deleted"), onError: (e) => print("Error updating document $e"),
          );
        }
      }

      Navigator.pop(context, 'Aceptar');
    } catch (e) {
      print(e);
    }
  }

  EliminarDocDeuda(String IdDeuda) async {

    try {
      FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Deudas").doc(IdDeuda).delete()
          .then((doc) => print("Document deleted"), onError: (e) => print("Error updating document $e"),
      );
      RecargarValorDeudas(widget.datos.Deudas_docCliente);
    } catch (e) {
      print(e);
    }
  }

  ActualizarDatosDeuda() async{

    try{
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Deudas");
      QuerySnapshot Deuda = await ref.get();

      if(Deuda.docs.length != 0){
        if (producto.text != "" || valor.text != "") {
          for(var cursor in Deuda.docs){
            if(widget.datos.docDeuda == cursor.id) {
              await firebase
                  .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Deudas")
                  .doc(cursor.id)
                  .set({
                "Producto": producto.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
                "Valor": valor.text.replaceAll(",", ""),
                "Fecha" : cursor.get("Fecha"),
              });
              RecargarValorDeudas(widget.datos.Deudas_docCliente);
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

  RecargarValorDeudas(String IdCliente) async {

    String Valores = "";
    int SumaTotalDeuda = 0;

    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(IdCliente).collection("Deudas");
      QuerySnapshot deudas = await ref.get();

      for(var cursor in deudas.docs){
        Valores = cursor.get("Valor");
        SumaTotalDeuda += int.parse(Valores);
      }

      SumaTotalDeuda = int.parse(SumaTotalDeuda.toString().replaceAll(".0", ""));

      CollectionReference ref2=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores");
      QuerySnapshot usuario = await ref2.get();

      for(var cursor in usuario.docs){
        if(IdCliente == cursor.id) {
          await firebase
              .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores")
              .doc(cursor.id)
              .set({
            "DeudaTotal": SumaTotalDeuda.toString(),
            "AbonoTotal": cursor.get("AbonoTotal"),
            "Nombre": cursor.get("Nombre"),
            "Telefono": cursor.get("Telefono"),
            "Notas": cursor.get("Notas"),
            "Fecha" : cursor.get("Fecha"),
          });
          setState((){
            BuscarDocCliente(IdCliente);
          });
        }
      }

    }catch(e){
      print(e);
    }
  }

  BuscarDocCliente(String IdCliente) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.id == IdCliente) {
            widget.datos.Deudas_NombreCliente = cursor.get("Nombre");
            widget.datos.Deudas_TelefonoCliente = cursor.get("Telefono");
            widget.datos.Deudas_NotasCliente = cursor.get("Notas");
            widget.datos.Deudas_docCliente = cursor.id;
            widget.datos.Deudas_DeudaTotal = cursor.get("DeudaTotal");
            widget.datos.Deudas_AbonoTotal = cursor.get("AbonoTotal");
          }
        }
        Navigator.pop(context, 'Agregar');
        Navigator.push(context, MaterialPageRoute(builder: (context) => Ver_Cliente_Deudor(widget.datos)));
      }

    } catch (e) {
      print(e);
    }
  }

  BuscarDocDeuda(String IdDeuda) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Deudas");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.id == IdDeuda) {
            producto.text = cursor.get("Producto");
            valor.text = cursor.get("Valor");
            widget.datos.docDeuda = cursor.id;
          }
        }
      }

    } catch (e) {
      print(e);
    }
  }

  RegistroAbonoDeudor() async {
    int banUsuario = 0;

    try{
      if(observacion.text != "" && valor.text != ""){
        banUsuario = 1;
        await firebase
            .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Abonos")
            .doc()
            .set({
          "Observacion": observacion.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
          "Valor": valor.text.replaceAll(",", ""),
          "Fecha" : now,
        });
      }
      else{
        mensaje("Error", "Registro incorrecto, datos incompletos");
      }
    }catch(e){
      print(e);
    }

    if(banUsuario == 1){
      RecargarValorAbonos(widget.datos.Deudas_docCliente);
      producto.clear();
      valor.clear();
    }
  }

  RecargarValorAbonos(String IdCliente) async {

    String Valores = "";
    int SumaTotalAbono = 0;

    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(IdCliente).collection("Abonos");
      QuerySnapshot deudas = await ref.get();

      for(var cursor in deudas.docs){
        Valores = cursor.get("Valor");
        SumaTotalAbono += int.parse(Valores);
      }

      SumaTotalAbono = int.parse(SumaTotalAbono.toString().replaceAll(".0", ""));

      CollectionReference ref2=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores");
      QuerySnapshot usuario = await ref2.get();

      for(var cursor in usuario.docs){
        if(IdCliente == cursor.id) {
          await firebase
              .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores")
              .doc(cursor.id)
              .set({
            "AbonoTotal": SumaTotalAbono.toString(),
            "DeudaTotal": cursor.get("DeudaTotal"),
            "Nombre": cursor.get("Nombre"),
            "Telefono": cursor.get("Telefono"),
            "Notas": cursor.get("Notas"),
            "Fecha" : cursor.get("Fecha"),
          });
          setState((){
            BuscarDocCliente(IdCliente);
          });
        }
      }

    }catch(e){
      print(e);
    }
  }

  EliminarDocAbono(String IdDeuda) async {

    try {
      FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Abonos").doc(IdDeuda).delete()
          .then((doc) => print("Document deleted"), onError: (e) => print("Error updating document $e"),
      );
      RecargarValorAbonos(widget.datos.Deudas_docCliente);
    } catch (e) {
      print(e);
    }
  }

  BuscarDocAbono(String IdDeuda) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Abonos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.id == IdDeuda) {
            observacion.text = cursor.get("Observacion");
            valor.text = cursor.get("Valor");
            widget.datos.docDeuda = cursor.id;
          }
        }
      }

    } catch (e) {
      print(e);
    }
  }

  ActualizarDatosAbono() async{

    try{
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Abonos");
      QuerySnapshot Deuda = await ref.get();

      if(Deuda.docs.length != 0){
        if (observacion.text != "" || valor.text != "") {
          for(var cursor in Deuda.docs){
            if(widget.datos.docDeuda == cursor.id) {
              await firebase
                  .collection("Usuarios").doc(widget.datos.docUsuario).collection("UsuariosDeudores").doc(widget.datos.Deudas_docCliente).collection("Abonos")
                  .doc(cursor.id)
                  .set({
                "Observacion": observacion.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
                "Valor": valor.text.replaceAll(",", ""),
                "Fecha" : cursor.get("Fecha"),
              });
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

  @override
  Widget build(BuildContext context) {

    Color color = Colors.black;

    Widget Resumen = Container(
      margin: EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          //Nombre en resumen
          Container(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text('Nombre: '+widget.datos.Deudas_NombreCliente,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          //Posible celular en resumen
          if(widget.datos.Deudas_TelefonoCliente != "")...[
            Text('Celular: '+widget.datos.Deudas_TelefonoCliente,
              style: TextStyle(color: color, fontSize: 15),
            ),
          ],
          //Posible notas en resumen
          if(widget.datos.Deudas_NotasCliente != "")...[
            Text('Notas: '+widget.datos.Deudas_NotasCliente,
              style: TextStyle(color: color, fontSize: 15),
            ),
          ],
          Padding(padding: EdgeInsets.all(5)),
          //Botones en resumen
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Deuda Total
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: color,
                    width: 1,
                  ),
                ),
                child: MaterialButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            Text('Deuda Total \n${NumberFormat.simpleCurrency().format(int.parse(widget.datos.Deudas_DeudaTotal)-int.parse(widget.datos.Deudas_AbonoTotal))}',
                              style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        //Texto de deuda Total
                        content: Container(
                          child: Row(
                            children: [
                              Text('La deuda total es: '+NumberFormat.simpleCurrency().format(int.parse(widget.datos.Deudas_DeudaTotal))),
                            ],
                          ),
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.00)),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              Padding(padding: EdgeInsets.all(5)),
              //Abonos
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: color,
                    width: 1,
                  ),
                ),
                child: MaterialButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Container(
                          child: Column(
                            children: [
                              Text('Abonos\n${NumberFormat.simpleCurrency().format(int.parse(widget.datos.Deudas_AbonoTotal))}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    observacion.text = "";
                    valor.text = "";
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) =>
                          AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                            titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                            title: const Text('Agregar Abono'),
                            contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                            content:  const Text('A continuacion ingrese el siguiente abono'),
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
                                            hintText: "Digite la observacion del abono",
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
                                            hintText: "Digite el valor del abono",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            )
                                        ),
                                      ),
                                    ),
                                    //Abonar o Cancelar
                                    Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            MaterialButton(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                              color: Colors.blue,
                                              onPressed: () {
                                                RegistroAbonoDeudor();
                                                Navigator.pop(context, 'Abonar');
                                              },
                                              child: const Text('Abonar',
                                                style: TextStyle(fontSize: 16.0, color: Colors.white),
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
                                              child: const Text('Cancelar',
                                                style: TextStyle(fontSize: 16.0, color: Colors.white),
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                    //Titulo detalle abonos
                                    Padding(padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(bottom: 0),
                                            child: Text('Detalle Abonos',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Detalle abonos
                                    StreamBuilder(
                                      stream: FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection('UsuariosDeudores').doc(widget.datos.Deudas_docCliente).collection('Abonos').snapshots(),
                                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                        if (!snapshot.hasData){
                                          return CircularProgressIndicator();
                                        }
                                        return Container(
                                          height: 100,
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
                                                              title: Text(snapshot.data!.docs[index].get("Observacion")),
                                                              subtitle: Text('${NumberFormat.simpleCurrency().format(int.parse(snapshot.data!.docs[index].get("Valor")))}\nFecha: ${snapshot.data!.docs[index].get("Fecha")}'),
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
                                                                title: const Text('Actualizar Abono'),
                                                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                content: const Text('A continuacion modifique los datos del abono'),
                                                                actions: <Widget>[
                                                                  //Nombre del abono
                                                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                                                                    child: TextField(
                                                                      controller: observacion,
                                                                      textCapitalization: TextCapitalization.words,
                                                                      decoration: InputDecoration(
                                                                        labelText: "Observacion del abono",
                                                                        hintText: "Digite la observacion del abono",
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
                                                                        labelText: "Valor del abono",
                                                                        hintText: "Digite el valor del abono",
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
                                                                          },
                                                                          child: const Text('Actualizar',
                                                                            style: TextStyle(fontSize: 16.0, color: Colors.white),
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
                                                                          child: const Text('Cancelar',
                                                                            style: TextStyle(fontSize: 16.0, color: Colors.white),
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
                                                                title: const Text('Eliminar Abonos'),
                                                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                                content: const Text('¿Seguro quiere eliminar el abono?'),
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
                                                                          },
                                                                          child: const Text('Aceptar',
                                                                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                                                                          ),
                                                                        ),

                                                                        MaterialButton(
                                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                          color: Colors.red,
                                                                          onPressed: () {
                                                                            Navigator.pop(context, 'Cancelar');
                                                                          },
                                                                          child: const Text('Cancelar',
                                                                            style: TextStyle(fontSize: 16.0, color: Colors.white),
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
                                  ],
                                )
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ),
              Padding(padding: EdgeInsets.all(5)),
              //Eliminar
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: color,
                    width: 1,
                  ),
                ),
                child: MaterialButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Container(
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: color, size: 20),
                                Text('Eliminar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: color,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                              titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                              title: const Text('Eliminar Usuario'),
                              contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                              content: const Text('¿Seguro quiere eliminar el usuario?'),
                              actions: <Widget>[
                                Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      MaterialButton(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                        color: Colors.blue,
                                        onPressed: () {
                                          EliminarDocCliente();
                                          Navigator.pop(context, 'Aceptar');
                                        },
                                        child: const Text('Aceptar',
                                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                                        ),
                                      ),
                                      MaterialButton(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                        color: Colors.red,
                                        onPressed: () {
                                          Navigator.pop(context, 'Cancelar');
                                        },
                                        child: const Text('Cancelar',
                                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                                        ),
                                      )
                                    ]
                                  )
                                ),
                              ],
                            ),
                      );
                    }
                ),
              ),
            ]
          )
        ],
      ),
    );

    Widget Detalle = StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection('UsuariosDeudores').doc(widget.datos.Deudas_docCliente).collection('Deudas').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData){
          return CircularProgressIndicator();
        }
        return ListView.builder(
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
                            title: Text(snapshot.data!.docs[index].get("Producto")),
                            subtitle: Text('${NumberFormat.simpleCurrency().format(int.parse(snapshot.data!.docs[index].get("Valor")))}\nFecha: ${snapshot.data!.docs[index].get("Fecha")}'),
                            leading: CircleAvatar(
                              child: Text(snapshot.data!.docs[index].get("Producto").substring(0,1)),
                            ),
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
                                title: const Text('Actualizar Deuda'),
                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                content: const Text('A continuacion modifique los datos de la deuda'),
                                actions: <Widget>[
                                  //Nombre de la deuda
                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                                    child: TextField(
                                      controller: producto,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: InputDecoration(
                                          labelText: "Nombre de la deuda",
                                          hintText: "Digite el nombre de la deuda",
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
                                          hintText: "Digite el valor de la deuda",
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
                                            },
                                            child: const Text('Actualizar',
                                              style: TextStyle(fontSize: 16.0, color: Colors.white),
                                            ),
                                          ),

                                          MaterialButton(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                            color: Colors.red,
                                            onPressed: () {
                                              Navigator.pop(context, 'Cancelar');
                                            },
                                            child: const Text('Cancelar',
                                              style: TextStyle(fontSize: 16.0, color: Colors.white),
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
                                title: const Text('Eliminar Deuda'),
                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                content: const Text('¿Seguro quiere eliminar la deuda?'),
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
                                          },
                                          child: const Text('Aceptar',
                                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                                          ),
                                        ),

                                        MaterialButton(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                          color: Colors.red,
                                          onPressed: () {
                                            Navigator.pop(context, 'Cancelar');
                                          },
                                          child: const Text('Cancelar',
                                            style: TextStyle(fontSize: 16.0, color: Colors.white),
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
        );
      }
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Deudor '+widget.datos.Deudas_NombreCliente),
      ),
      body: Column(
        children: [
          Resumen,
          //Titulo detalle deudas
          Padding(padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Text('Detalle Deudas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Detalle,
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          producto.text = "";
          valor.text = "";
          showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
              AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                title: const Text('Agregar Deuda'),
                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                content: const Text('A continuacion ingrese los datos de la deuda'),
                actions: <Widget>[
                  //Nombre de la deuda
                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                    child: TextField(
                      controller: producto,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          labelText: "Nombre de la deuda",
                          hintText: "Digite el nombre de la deuda",
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
                          hintText: "Digite el valor de la deuda",
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
                            RegistroDeuda();
                            Navigator.pop(context, 'Agregar');
                          },
                          child: const Text('Agregar',
                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),

                        MaterialButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          color: Colors.red,
                          onPressed: () {
                            Navigator.pop(context, 'Cancelar');
                          },
                          child: const Text('Cancelar',
                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ]
                    ),
                  ),
                ],
              ),
          );
        },
        backgroundColor: Colors.red.shade400,
        child: const Icon(Icons.add),
        tooltip: 'Agregar Deuda',
      ),
    );
  }

  void mensaje(String titulo, String mensaje){
    showDialog(
      context: context,
      builder: (buildcontext){
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: <Widget>[],
        );
      }
    );
  }
}

