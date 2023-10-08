import 'package:app_a/Borrar/Deudas_y_Deudores.dart';
import 'package:app_a/Borrar/Ingreso%20y%20Registro.dart';
import 'package:app_a/2_transferenciaDeDatos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Gastos_Mensuales extends StatefulWidget {
  final transferencia_de_Datos datos;
  const Gastos_Mensuales(this.datos, {Key? key}) : super(key: key);

  @override
  Gastos_Mensuales_App createState() => Gastos_Mensuales_App();
}

class Gastos_Mensuales_App extends State<Gastos_Mensuales> {
  final firebase = FirebaseFirestore.instance;
  TextEditingController deber = TextEditingController();
  TextEditingController valor = TextEditingController();
  TextEditingController categoria = TextEditingController();
  TextEditingController reservado = TextEditingController();
  TextEditingController yapago = TextEditingController();
  TextEditingController mes = TextEditingController();
  TextEditingController pagorecibidomes = TextEditingController();
  bool banReservado = false;
  bool banYapago = false;
  final CurrencyTextInputFormatter FormatoDinero = CurrencyTextInputFormatter(locale: 'ko', decimalDigits: 0, symbol: ' ');

  RegistroDeberes() async {
    int banUsuario = 0;

    try {
      if (deber.text != "" && valor.text != "" && categoria.text != "") {
        if (widget.datos.MesDropdownValue != "Agregar Mes") {
          banUsuario = 1;
          await firebase
              .collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue)
              .doc()
              .set({
            "Deber": deber.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
            "Valor": valor.text.replaceAll(",", ""),
            "Categoria": categoria.text,
            "Reservado": banReservado,
            "Yapago": banYapago
          });
          Cargar_Gastos_Totales(widget.datos.MesDropdownValue);
        }else{
          mensaje("Error", "Registro incorrecto, por favor seleccione un mes");
        }
      }else {
        mensaje("Error", "Registro incorrecto, datos incompletos");
      }
    } catch (e) {
      print(e);
    }

    if (banUsuario == 1) {
      deber.clear();
      valor.clear();
      categoria.clear();
    }
  }

  Cargar_Gastos_Totales(String Mes) async{

    String Valores = "";
    int SumaTotalGastos = 0;

    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue);
      QuerySnapshot Gastos = await ref.get();

      for(var cursor in Gastos.docs){
        Valores = cursor.get("Valor");
        SumaTotalGastos += int.parse(Valores);
      }

      SumaTotalGastos = int.parse(SumaTotalGastos.toString().replaceAll(".0", ""));

      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales");
      QuerySnapshot Meses = await ref2.get();

      if (Meses.docs.length != 0) {
        for (var cursor in Meses.docs) {
          if (cursor.id == widget.datos.MesDropdownValue) {
            await firebase
                .collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales")
                .doc(widget.datos.MesDropdownValue)
                .set({
              "Mes": cursor.get("Mes"),
              "TotalGastos": SumaTotalGastos.toString(),
              "GastosReservados": cursor.get("GastosReservados"),
              "GastosYapago": cursor.get("GastosYapago"),
              "PagoRecibidoMes": cursor.get("PagoRecibidoMes"),
            });
            setState((){
              Cargar_Gastos_Reservados(Mes);
            });
          }
        }
      }
    }catch(e){
      print(e);
    }
  }

  Cargar_Gastos_Reservados(String Mes) async{

    String Valores = "";
    int SumaGastosReservados = 0;

    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue);
      QuerySnapshot Gastos = await ref.get();

      for(var cursor in Gastos.docs){
        if(cursor.get("Reservado") == true){
          Valores = cursor.get("Valor");
          SumaGastosReservados += int.parse(Valores);
        }
      }

      SumaGastosReservados = int.parse(SumaGastosReservados.toString().replaceAll(".0", ""));

      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales");
      QuerySnapshot Meses = await ref2.get();

      if (Meses.docs.length != 0) {
        for (var cursor in Meses.docs) {
          if (cursor.id == widget.datos.MesDropdownValue) {
            await firebase
                .collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales")
                .doc(widget.datos.MesDropdownValue)
                .set({
              "Mes": cursor.get("Mes"),
              "TotalGastos": cursor.get("TotalGastos"),
              "GastosReservados": SumaGastosReservados.toString(),
              "GastosYapago": cursor.get("GastosYapago"),
              "PagoRecibidoMes": cursor.get("PagoRecibidoMes"),
            });
            setState((){
              Cargar_Gastos_Yapago(Mes);
            });
          }
        }
      }
    }catch(e){
      print(e);
    }
  }

  Cargar_Gastos_Yapago(String Mes) async{

    String Valores = "";
    int SumaGastosYapago = 0;

    try{
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue);
      QuerySnapshot Gastos = await ref.get();

      for(var cursor in Gastos.docs){
        if(cursor.get("Yapago") == true){
          Valores = cursor.get("Valor");
          SumaGastosYapago += int.parse(Valores);
        }
      }

      SumaGastosYapago = int.parse(SumaGastosYapago.toString().replaceAll(".0", ""));

      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales");
      QuerySnapshot Meses = await ref2.get();

      if (Meses.docs.length != 0) {
        for (var cursor in Meses.docs) {
          if (cursor.id == widget.datos.MesDropdownValue) {
            await firebase
                .collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales")
                .doc(widget.datos.MesDropdownValue)
                .set({
              "Mes": cursor.get("Mes"),
              "TotalGastos": cursor.get("TotalGastos"),
              "GastosReservados": cursor.get("GastosReservados"),
              "GastosYapago": SumaGastosYapago.toString(),
              "PagoRecibidoMes": cursor.get("PagoRecibidoMes"),
            });
            setState((){
              BuscarDocGastos(Mes);
            });
          }
        }
      }
    }catch(e){
      print(e);
    }
  }

  BuscarDocGastos(String Mes) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("GastosMensuales");
      QuerySnapshot meses = await ref.get();

      if (meses.docs.length != 0) {
        for (var cursor in meses.docs) {
          if (cursor.id == Mes) {
            widget.datos.MesGastos = cursor.get("Mes");
            widget.datos.GastosTotales = cursor.get("TotalGastos");
            widget.datos.GastosReservados = cursor.get("GastosReservados");
            widget.datos.GastosYapago = cursor.get("GastosYapago");
            widget.datos.PagoRecibidoMes = cursor.get("PagoRecibidoMes");
          }
        }
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }
  /*
  BuscarDocGastosMes(String IdCliente, context) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue);
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.id == IdCliente) {
            deber.text = widget.datos.DeberGastos = cursor.get("Deber");
            valor.text = widget.datos.ValorGastos = cursor.get("Valor");
            categoria.text = widget.datos.CategoriaGastos = cursor.get("Categoria");
            banReservado = cursor.get("Reservado");
            banYapago = cursor.get("Yapago");
            widget.datos.docGastos = cursor.id;
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  ActualizarDatosGastos() async{

    try{
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue);
      QuerySnapshot usuario = await ref.get();

      if(usuario.docs.length != 0){
        if (deber.text != "" && valor.text != "" && categoria.text != "") {
          for(var cursor in usuario.docs){
            if(widget.datos.docGastos == cursor.id) {
              await firebase
                  .collection("Usuarios").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue)
                  .doc(cursor.id)
                  .set({
                "Deber": deber.text.split(" ").map((str) => str[0].toUpperCase()+str.substring(1)).join(" "),
                "Valor": valor.text,
                "Categoria": categoria.text,
                "Reservado": cursor.get("Reservado"),
                "Yapago": cursor.get("Yapago"),
              });
              BuscarDocGastosMes(cursor.id, context);
              Cargar_Gastos_Totales(widget.datos.MesDropdownValue);
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

  ActualizarDatosGastosReservado(bool banReservado, String IdGastos) async{

    try{
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue);
      QuerySnapshot usuario = await ref.get();

      if(usuario.docs.length != 0){
        for(var cursor in usuario.docs){
          if(IdGastos == cursor.id){
            if(banReservado == true) {
              await firebase
                  .collection("Usuarios").doc(widget.datos.docUsuario)
                  .collection("GastosMensuales").doc(
                  widget.datos.MesDropdownValue).collection(
                  widget.datos.MesDropdownValue)
                  .doc(cursor.id)
                  .set({
                "Deber": cursor.get("Deber"),
                "Valor": cursor.get("Valor"),
                "Categoria": cursor.get("Categoria"),
                "Reservado": banReservado,
                "Yapago": cursor.get("Yapago"),
              });
              BuscarDocGastosMes(cursor.id, context);
              Cargar_Gastos_Reservados(widget.datos.MesDropdownValue);
            }
            else if(banReservado == false){
              await firebase
                  .collection("Usuarios").doc(widget.datos.docUsuario)
                  .collection("GastosMensuales").doc(
                  widget.datos.MesDropdownValue).collection(
                  widget.datos.MesDropdownValue)
                  .doc(cursor.id)
                  .set({
                "Deber": cursor.get("Deber"),
                "Valor": cursor.get("Valor"),
                "Categoria": cursor.get("Categoria"),
                "Reservado": banReservado,
                "Yapago": banReservado,
              });
              BuscarDocGastosMes(cursor.id, context);
              Cargar_Gastos_Reservados(widget.datos.MesDropdownValue);
            }
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

  ActualizarDatosGastosYapago(bool banYapago, String IdGastos) async{

    try{
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue);
      QuerySnapshot usuario = await ref.get();

      if(usuario.docs.length != 0){
        for(var cursor in usuario.docs){
          if(IdGastos == cursor.id){
            await firebase
                .collection("Usuarios").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue)
                .doc(cursor.id)
                .set({
              "Deber": cursor.get("Deber"),
              "Valor": cursor.get("Valor"),
              "Categoria": cursor.get("Categoria"),
              "Reservado": cursor.get("Reservado"),
              "Yapago": banYapago,
            });
            BuscarDocGastosMes(cursor.id, context);
            Cargar_Gastos_Yapago(widget.datos.MesDropdownValue);
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

  SeleccionMes(String Mes) async {

    try{
      Cargar_Gastos_Totales(Mes);
      Cargar_Gastos_Reservados(Mes);
      Cargar_Gastos_Yapago(Mes);

    }catch(e){
      print(e);
    }
  }

  BuscarDocPagoRecibido() async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("GastosMensuales");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.id == widget.datos.MesDropdownValue) {
            pagorecibidomes.text = widget.datos.PagoRecibidoMes = cursor.get("PagoRecibidoMes");
            widget.datos.docGastos = cursor.id;
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  ActualizarPagoRecibido() async{

    try{
      CollectionReference ref2 = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("GastosMensuales");
      QuerySnapshot Meses = await ref2.get();

      if (Meses.docs.length != 0) {
        for (var cursor in Meses.docs) {
          if (cursor.id == widget.datos.MesDropdownValue) {
            await firebase
                .collection("Usuarios").doc(widget.datos.docUsuario).collection("GastosMensuales")
                .doc(widget.datos.MesDropdownValue)
                .set({
              "Mes": cursor.get("Mes"),
              "TotalGastos": cursor.get("TotalGastos"),
              "GastosReservados": cursor.get("GastosReservados"),
              "GastosYapago": cursor.get("GastosYapago"),
              "PagoRecibidoMes": pagorecibidomes.text.replaceAll(",", ""),
            });
            setState((){
              BuscarDocGastos(widget.datos.MesDropdownValue);
            });
          }
        }
      }
    }catch(e){
      print(e);
    }
  }

  */

  CerrarSesion() async{

    try{
      CollectionReference ref=FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo");
      QuerySnapshot usuario = await ref.get();

      if(usuario.docs.length != 0){
        for(var cursor in usuario.docs){
          if(widget.datos.docUsuario == cursor.id) {
            await firebase
                .collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo")
                .doc(cursor.id)
                .set({
              "Activo": "NO",
              "Fecha": cursor.get("Fecha"),
              "ID": cursor.get("ID"),
              "ID-Dispositivo": cursor.get("ID-Dispositivo"),
            });
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

    //Da color a los checkBox
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                leading: Icon(
                  Icons.home,
                ),
                title: const Text('Deudas, Prestamos, Ahorros, Informe y Movimientos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Deudas_y_Deudores(widget.datos)));
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.train,
                ),
                title: const Text('Gastos Mensuales'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.train,
                ),
                title: const Text('Cerrar Sesion'),
                onTap: () {
                  CerrarSesion();
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Ingreso_y_Registro(widget.datos)));
                },
              )
            ],
          ),
        ),

        appBar: AppBar(
          title: Text('Control de Gastos Mensuales'),
          //Mostrar la lista desplegable de los meses
            /*
          actions: <Widget>[
            DropdownButton<String>(
              value: widget.datos.MesDropdownValue,
              style: const TextStyle(color: Colors.white),
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 35,
              dropdownColor: Colors.blueAccent,
              underline: Container(
                height: 1,
                color: Colors.blueGrey,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  SeleccionMes(widget.datos.MesDropdownValue = newValue!);
                });
              },
              items: widget.datos.MesesGastos.map<DropdownMenuItem<String>>((String value) =>
                  DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  )
              ).toList(),
            ),
          ]
          */
        ),
        /*
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Agregar Mes
            if(widget.datos.MesDropdownValue == 'Agregar Mes')...[
              Padding(padding: EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 5),
                child: Container(
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    actions: <Widget>[
                      //Titulo
                      Padding(padding: EdgeInsets.only(left: 30, top: 30, right: 185, bottom: 10),
                        child: Text('Agregar Deber',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      //Contenido
                      Padding(padding: EdgeInsets.only(left: 30, top: 10, right: 30, bottom: 10),
                        child: Text('A continuacion ingrese los datos del deber',
                          style: TextStyle(fontSize: 17),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      //Deber
                      Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                        child: TextField(
                          controller: deber,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                              labelText: "Nombre del deber",
                              hintText: "Digite el nombre del deber",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              )
                          ),
                        ),
                      ),
                      //Valor
                      Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FormatoDinero],
                          controller: valor,
                          decoration: InputDecoration(
                              labelText: "Valor del deber",
                              hintText: "Digite el valor del deber",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              )
                          ),
                        ),
                      ),
                      //Categoria
                      Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
                        child: TextField(
                          controller: categoria,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                              labelText: "Categoria del deber",
                              hintText: "Digite la categoria del deber",
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
                                  banReservado = false;
                                  banYapago = false;
                                  RegistroDeberes();
                                  Navigator.pop(context, 'Registrar');
                                },
                                child: const Text('Registrar',
                                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                                ),
                              ),

                              MaterialButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                color: Colors.red,
                                onPressed: () {
                                  Navigator.pop(context, 'Cancelar');
                                  deber.clear();
                                  valor.clear();
                                  categoria.clear();
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
                )
              )
            ],
            //Resumen
            if(widget.datos.MesDropdownValue != 'Agregar Mes')...[
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.shade100,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                    border: Border.all(
                      color: Colors.deepPurpleAccent.shade100,
                      width: 2,
                    ),
                  ),
                  child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 0, left: 25, right: 25, top: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Pago de Nomina
                              Container(
                                padding: const EdgeInsets.only(bottom: 0, left: 0, right: 0, top: 0),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurpleAccent.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: MaterialButton(
                                  child: Text('Pago Recibido: \n'+NumberFormat.simpleCurrency().format(int.parse(widget.datos.PagoRecibidoMes)),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  onPressed: () {
                                    BuscarDocPagoRecibido();
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                        AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                          actions: <Widget>[
                                            if(widget.datos.MesDropdownValue != 'Agregar Mes')...[
                                              //Titulo
                                              Padding(padding: EdgeInsets.only(left: 30, top: 30, right: 185, bottom: 10),
                                                child: Text('Pago Recibido',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                  textAlign: TextAlign.justify,
                                                ),
                                              ),
                                              //Contenido
                                              Padding(padding: EdgeInsets.only(left: 30, top: 10, right: 30, bottom: 10),
                                                child: Text('A continuacion modifique el pago recibido:',
                                                  style: TextStyle(fontSize: 17),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                              //Valor
                                              Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                                                child: TextField(
                                                  keyboardType: TextInputType.phone,
                                                  inputFormatters: [FormatoDinero],
                                                  controller: pagorecibidomes,
                                                  decoration: InputDecoration(
                                                      labelText: "Valor del pago recibido",
                                                      hintText: "Digite el valor del pago recibido",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(15),
                                                      )
                                                  ),
                                                ),
                                              ),
                                              //Actualizar o Cancelar
                                              Padding(padding: EdgeInsets.only(left: 25, top: 10, right: 25, bottom: 10),
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      MaterialButton(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                        color: Colors.blue,
                                                        onPressed: () {
                                                          ActualizarPagoRecibido();
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
                                                          pagorecibidomes.clear();
                                                        },
                                                        child: const Text('Cancelar',
                                                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                    );
                                  },
                                )
                              ),
                              //Gastos Totales
                              Container(
                                padding: const EdgeInsets.only(bottom: 5, left: 18, right: 10, top: 5),
                                child: Text('Gastos Totales: \n'+NumberFormat.simpleCurrency().format(int.parse(widget.datos.GastosTotales)),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 0, left: 25, right: 25, top: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Gastos Reservado
                              Container(
                                padding: const EdgeInsets.only(bottom: 5, left: 10, right: 10, top: 5),
                                child: Text('Gastos Reservados: \n'+NumberFormat.simpleCurrency().format(int.parse(widget.datos.GastosReservados)),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                              ),
                              //Gastos Ya Pagos
                              Container(
                                padding: const EdgeInsets.only(bottom: 5, left: 10, right: 10, top: 5),
                                child: Text('Gastos Ya Pagos: \n'+NumberFormat.simpleCurrency().format(int.parse(widget.datos.GastosYapago)),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                              ),
                            ]
                          ),
                        ),
                      ]
                  )
              ),
            ],
            //Titulo de detalle de Gastos
            if(widget.datos.MesDropdownValue != 'Agregar Mes')...[
              Padding(padding: EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Detalle
                    Padding(padding: EdgeInsets.only(left: 70, top: 0, right: 40, bottom: 0),
                      child: Text('Detalle Gastos',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    //Reservado
                    Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 15, bottom: 0),
                      child: Text('Reservado',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    //Ya Pago
                    Padding(padding: EdgeInsets.only(left: 18, top: 0, right: 25, bottom: 0),
                      child: Text('Ya Pago',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),
            ],
            //Detalle Gastos
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docDispositivo).collection("UsuariosDispositivo").doc(widget.datos.docUsuario).collection("GastosMensuales").doc(widget.datos.MesDropdownValue).collection(widget.datos.MesDropdownValue).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            child: Row(
                                children: [
                                  //Gastos
                                  Expanded(
                                    child: MaterialButton(
                                      child: Column(
                                        children: <Widget>[
                                          ListTile(contentPadding: EdgeInsets.fromLTRB(3, 6, 3, 6),
                                            title: Text('Valor: ${NumberFormat.simpleCurrency().format(int.parse(snapshot.data!.docs[index].get("Valor")))}'),
                                            subtitle: Text('Deber: ${snapshot.data!.docs[index].get("Deber")}\nCategoria: ${snapshot.data!.docs[index].get("Categoria")}'),
                                            leading: CircleAvatar(
                                              child: Text(snapshot.data!.docs[index].get("Deber").substring(0, 1)),
                                            ),
                                          ),
                                        ]
                                      ),
                                      onPressed: () {
                                        BuscarDocGastosMes(snapshot.data!.docs[index].id, context);
                                        showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                titlePadding: EdgeInsets.fromLTRB(40, 30, 40, 10),
                                                title: const Text('Actualizar Deber'),
                                                contentPadding: EdgeInsets.fromLTRB(40,10,40, 10),
                                                content: const Text('A continuacion modifique los datos'),
                                                actions: <Widget>[
                                                  //Deber
                                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                                                    child: TextField(
                                                      controller: deber,
                                                      textCapitalization: TextCapitalization.words,
                                                      decoration: InputDecoration(
                                                          labelText: "Nombre del deber",
                                                          hintText: "Digite el nombre del deber",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(15),
                                                          )
                                                      ),
                                                    ),
                                                  ),
                                                  //Valor
                                                  Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                                                    child: TextField(
                                                      keyboardType: TextInputType.phone,
                                                      controller: valor,
                                                      decoration: InputDecoration(
                                                          labelText: "Valor del deber",
                                                          hintText: "Digite el valor del deber",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(15),
                                                          )
                                                      ),
                                                    ),
                                                  ),
                                                  //Categoria
                                                  Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
                                                    child: TextField(
                                                      controller: categoria,
                                                      textCapitalization: TextCapitalization.words,
                                                      decoration: InputDecoration(
                                                          labelText: "Categoria del deber",
                                                          hintText: "Digite la categoria del deber",
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
                                                            ActualizarDatosGastos();
                                                            Navigator.pop(context, 'Actualizar');
                                                          },
                                                          child: const Text('Actualizar',
                                                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                                                          ),
                                                        ),

                                                        MaterialButton(
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                          color: Colors.red,
                                                          onPressed: () => Navigator.pop(context, 'Cancelar'),
                                                          child: const Text('Cancelar',
                                                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                    ),
                                  ),
                                  //Reservado
                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                                    child: Checkbox(
                                      checkColor: Colors.white,
                                      fillColor: MaterialStateProperty.resolveWith(getColor),
                                      value: snapshot.data!.docs[index].get("Reservado"),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          ActualizarDatosGastosReservado(banReservado=value!, snapshot.data!.docs[index].id);
                                        });
                                      },
                                    )
                                  ),
                                  //Pago Realizado
                                  Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                                    child: Checkbox(
                                      checkColor: Colors.white,
                                      fillColor: MaterialStateProperty.resolveWith(getColor),
                                      value: snapshot.data!.docs[index].get("Yapago"),
                                      onChanged: (bool? value) {
                                        if(snapshot.data!.docs[index].get("Reservado") == true)[
                                          setState(() {
                                            ActualizarDatosGastosYapago(banYapago=value!, snapshot.data!.docs[index].id);
                                          })
                                        ];else[
                                          mensaje("Error", "Es necesario reservar primero")
                                        ];
                                      },
                                    )
                                  )
                                ]
                            )
                        );
                      }
                  );
                },
              )
            ),
          ]
        ),
        */
        floatingActionButton: FloatingActionButton (
          onPressed: () {
            deber.text = "";
            valor.text = "";
            categoria.text = "";
            showDialog<String>(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    actions: <Widget>[
                      if(widget.datos.MesDropdownValue != 'Agregar Mes')...[
                        //Titulo
                        Padding(padding: EdgeInsets.only(left: 30, top: 30, right: 185, bottom: 10),
                          child: Text('Agregar Deber',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        //Contenido
                        Padding(padding: EdgeInsets.only(left: 30, top: 10, right: 30, bottom: 10),
                          child: Text('A continuacion ingrese los datos del deber',
                            style: TextStyle(fontSize: 17),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        //Deber
                        Padding(padding: EdgeInsets.only(left: 25, top: 0, right: 25, bottom: 0),
                          child: TextField(
                            controller: deber,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                                labelText: "Nombre del deber",
                                hintText: "Digite el nombre del deber",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                )
                            ),
                          ),
                        ),
                        //Valor
                        Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 0),
                          child: TextField(
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FormatoDinero],
                            controller: valor,
                            decoration: InputDecoration(
                                labelText: "Valor del deber",
                                hintText: "Digite el valor del deber",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                )
                            ),
                          ),
                        ),
                        //Categoria
                        Padding(padding: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
                          child: TextField(
                            controller: categoria,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                                labelText: "Categoria del deber",
                                hintText: "Digite la categoria del deber",
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
                                    banReservado = false;
                                    banYapago = false;
                                    RegistroDeberes();
                                    Navigator.pop(context, 'Registrar');
                                  },
                                  child: const Text('Registrar',
                                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                                  ),
                                ),

                                MaterialButton(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                  color: Colors.red,
                                  onPressed: () {
                                    Navigator.pop(context, 'Cancelar');
                                    deber.clear();
                                    valor.clear();
                                    categoria.clear();
                                  },
                                  child: const Text('Cancelar',
                                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                                  ),
                                ),
                              ]
                          ),
                        ),
                      ],
                    ],
                  ),
            );
          },
          backgroundColor: Colors.deepPurpleAccent,
          child: const Icon(Icons.add),
          tooltip: 'Agregar Cliente',
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