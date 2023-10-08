import 'package:app_a/2_transferenciaDeDatos.dart';
import 'package:app_a/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:math' as math;

class movimientos extends StatefulWidget {
  final transferencia_de_Datos datos;
  const movimientos(this.datos, {Key? key}) : super(key: key);

  @override
  movimientos_App createState() => movimientos_App();
}

class movimientos_App extends State<movimientos> {
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

  BuscarDocMovimientos(String IdCliente, context) async {

    try {
      CollectionReference ref = FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("Movimientos");
      QuerySnapshot base = await ref.get();

      if (base.docs.length != 0) {
        for (var cursor in base.docs) {
          if (cursor.id == IdCliente) {
            widget.datos.Movim_docMovim = cursor.id;
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: DefaultTabController(
      length: 3,
        child: Scaffold(
          appBar: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Deudas', height: 60),
              Tab(icon: Icon(Icons.business_center_outlined), text: 'Prestamos', height: 60),
              Tab(icon: Icon(Icons.savings_outlined), text: 'Ahorros', height: 60),
            ],
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.amber[800],
          ),
          body: Scaffold(
            backgroundColor: Color(0xFF95E59A),
            body: TabBarView(
              children: [
                Container(
                  child: Center(
                    child: Column(
                      children: [
                        //Detalle Movimientos
                        Expanded(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection("Movimientos").orderBy("Nombre", descending: true).snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) return CircularProgressIndicator();
                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    margin: EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 5),
                                    elevation: 3,
                                    child:  Column(
                                      children: [
                                        //nuevo
                                        MaterialButton(
                                          child: Column(
                                            children: <Widget>[
                                              ListTile(contentPadding: EdgeInsets.fromLTRB(3, 6, 3, 6),
                                                title: Text('${snapshot.data!.docs[index].get("Nombre")}', style: TextStyle(fontSize: SubTitulo)),
                                                subtitle: Text('Fecha Creacion: ${snapshot.data!.docs[index].get("FechaCreacion")}',
                                                    style: TextStyle(fontSize: Cuerpo)),
                                                leading: CircleAvatar(
                                                  backgroundColor: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1),
                                                  child: Text('${snapshot.data!.docs[index].get("Nombre").substring(0, 1)}'),
                                                ),
                                              ),
                                            ]
                                          ),
                                          onPressed: () {
                                            showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                AlertDialog(
                                                  backgroundColor: Colors.grey[300],
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                  titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                                                  title: Text('Historial de Movimientos',style: TextStyle(fontSize: VentanaTitulo), textAlign: TextAlign.center),
                                                  actions: <Widget>[
                                                    Padding(padding: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 20),
                                                      child: Column(
                                                        children: [
                                                          //Detalle Movimientos
                                                          StreamBuilder(
                                                            stream: FirebaseFirestore.instance.collection("Usuarios").doc(widget.datos.docUsuario).collection('Movimientos').doc(snapshot.data!.docs[index].id).collection('Deudas').orderBy("FechaMovimiento", descending: true).snapshots(),
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
                                                                      margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 10),
                                                                      elevation: 3,
                                                                      child: Column(
                                                                        children: [
                                                                          Padding(padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                                                                            child: Column(
                                                                              children: [
                                                                                //Descripcion
                                                                                Row(
                                                                                  children: [
                                                                                    Text("${snapshot.data!.docs[index].get("Descripcion")}", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                  ],
                                                                                ),
                                                                                //Fecha Movimiento
                                                                                Row(
                                                                                    children: [
                                                                                      Text("\t\t• Fecha: ${snapshot.data!.docs[index].get("FechaMovimiento")}", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                    ]
                                                                                ),
                                                                                if(snapshot.data!.docs[index].get("Nombre") != "")...[
                                                                                  //Nombre del cliente
                                                                                  Row(
                                                                                    children: [
                                                                                      Text("\t\t• Nombre: ${snapshot.data!.docs[index].get("Nombre")}", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                                if(snapshot.data!.docs[index].get("Telefono") != "")...[
                                                                                  //Telefono del cliente
                                                                                  Row(
                                                                                    children: [
                                                                                      Text("\t\t• Telefono: ${snapshot.data!.docs[index].get("Telefono")}", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                                if(snapshot.data!.docs[index].get("Notas") != "")...[
                                                                                  //Notas del cliente
                                                                                  Row(
                                                                                    children: [
                                                                                      Text("\t\t• Notas: ${snapshot.data!.docs[index].get("Notas")}", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                                if(snapshot.data!.docs[index].get("DeudaTotal") != "")...[
                                                                                  //Deuda total del cliente
                                                                                  Row(
                                                                                    children: [
                                                                                      Text("\t\t• Deuda total: ${snapshot.data!.docs[index].get("DeudaTotal")}", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                                if(snapshot.data!.docs[index].get("AbonoTotal") != "")...[
                                                                                  //Abono total del cliente
                                                                                  Row(
                                                                                    children: [
                                                                                      Text("\t\t• Abono total: ${snapshot.data!.docs[index].get("AbonoTotal")}", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                                if(snapshot.data!.docs[index].get("Observacion") != "")...[
                                                                                  //Observacion de la deuda del cliente
                                                                                  Row(
                                                                                    children: [
                                                                                      Text("\t\t• Observacion: ${snapshot.data!.docs[index].get("Observacion")}", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                                if(snapshot.data!.docs[index].get("Valor") != "")...[
                                                                                  //Valor de la deuda del cliente
                                                                                  Row(
                                                                                    children: [
                                                                                      Text("\t\t• Valor: ${snapshot.data!.docs[index].get("Valor")}", style: TextStyle(fontSize: VentanaCuerpo)),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ]
                                                                      )
                                                                    );
                                                                  }
                                                                ),
                                                              );
                                                            }
                                                          ),
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
                Icon(Icons.directions_transit),
                Icon(Icons.directions_bike),
              ],
            )
          ),
        )
      )
    );
  }
}