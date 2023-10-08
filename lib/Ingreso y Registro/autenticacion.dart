import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class autenticacion{

  Future<dynamic> Ingreso(String Correo, String Contrasena) async {
    late dynamic usuario;

    try{
      usuario = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: Correo, password: Contrasena)).user!;
      print(usuario);
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("No user found for that email.");
        usuario = "Usuario No Encontrado";
      } else if (e.code == 'wrong-password') {
        print("Wrong password provided for that user.");
        usuario = "Contraseña Incorrecta";
      }
    }

    return usuario;
  }

  Future<UserCredential> Registro(String Correo, String Contrasena) async {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(email: Correo, password: Contrasena);
  }

  Future<String?> OptenerID() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
}