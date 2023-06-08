import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'chuck.dart';

// Carga la url de la imagen de fondo
const urlBackgroundIMG =
    'https://album.mediaset.es/eimg/2023/02/24/la-intrahistoria-de-la-mitica-pelea-de-bruce-lee-y-chuck-norris_7a4a.jpg?w=480';

// API URL
const url = 'https://api.chucknorris.io/jokes/random';

void main() async => {
      // oculta la barra
      WidgetsFlutterBinding.ensureInitialized(),
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.black, //NavBar
          systemNavigationBarDividerColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.dark)),
      // Run the Application
      runApp(const MyApp()),
    };

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> futureChuckResponse;

  // llamado a la api
  Future<Chuck> chuckApiCall() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Trae el Json
      return Chuck.fromJson(jsonDecode(response.body));
    } else {
      // Sin conexion
      if (response.statusCode.isEven && response.body.isNotEmpty) {
        throw Exception('Error de conexion' +
            response.statusCode.toString() +
            ' ' +
            response.body);
      } else {
        throw Exception('Error de conexion');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Configuración de orientación del dispositivo: para desactivar el modo horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);

    // llamado a api
    futureChuckResponse = chuckApiCall();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                child: FutureBuilder<Chuck>(
                    future: chuckApiCall(),
                    builder: (context, snapshot) {
                      CircularProgressIndicator();
                      if (snapshot.hasData) {
                        return Stack(children: <Widget>[
                          Container(
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                            image: NetworkImage(
                                urlBackgroundIMG), //carga la imagen de fondo
                            fit: BoxFit.cover,
                          ))),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        20, 30, 35, 150),
                                    alignment: Alignment.topRight,
                                    // Widget que carga el resultado de la api
                                    child: Text(snapshot.data!.value,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 30,
                                          backgroundColor: Colors.red,
                                        ))),
                                // Boton de recarga
                                Container(
                                    alignment: Alignment.topCenter,
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 35, 0),
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              print("No eres rudo!");
                                              setState(() => _MyAppState());
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 60.0,
                                                      vertical: 20.0),
                                              primary: Colors.transparent,
                                              side: const BorderSide(
                                                  width: 0.85,
                                                  color: Colors.black),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                            ),
                                            child: const Text(
                                              "Inspirate papito", // button text message
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 22),
                                            )))),
                              ])
                        ]);
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('${snapshot.error}',
                                textAlign: TextAlign.center));
                      }
                      return Container(
                          child: Center(child: CircularProgressIndicator()));
                    }),
              ),
            )));
  }
}
