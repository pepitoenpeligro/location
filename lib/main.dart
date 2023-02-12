import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:convert';

import 'dart:io';

import 'package:lottie/lottie.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;

  return File('$path/locationsFileName.json');
}

Future<File> writePositionsToFile(List<PositionInterface> data) async {
  final file = await _localFile;

  // Write the file
  return file.writeAsString(data.toString());
}

void _eraseData() async {
  final file = await _localFile;
  if (await file.exists()) {
    file.delete();
  } else {
    print("File does not exist :)");
  }
}

Future<String> _readFile() async {
  try {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return "-";
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DementiApp',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(title: 'DementiApp'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Position? currentPosition;
  StreamSubscription<Position>? positionStream;
  List<PositionInterface>? positionRecollected = List.empty(growable: true);

  String locationsFileName = DateTime.now().millisecondsSinceEpoch.toString();

  bool statusRecording = false;

  bool showAnimationLocationTracking = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    positionStream?.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestLocationServicePermissions();
  }

  void _requestLocationServicePermissions() async {
    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print(
          'Location permissions are permanently denied, we cannot request permissions.');

      /// open app settings so that user changes permissions
      await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();

      return;
    }
  }

  void captureLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    print("Current Position $position");
    setState(() {
      currentPosition = position;
    });
  }

  void getLastKnownPosition() async {
    Position? position = await Geolocator.getLastKnownPosition();
  }

  void _goViewData() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DataHome(
              title: 'Json Raw Viewer',
            )));
  }

  void listenToLocationChanges() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        print(position == null ? 'Unknown' : '$position');
        setState(() {
          currentPosition = position;

          if (statusRecording) {
            PositionInterface newPosition = PositionInterface();
            newPosition.latitude = currentPosition?.latitude;
            newPosition.longitude = currentPosition?.longitude;
            newPosition.timestamp = DateTime.now().millisecondsSinceEpoch;
            positionRecollected?.add(newPosition);
            writePositionsToFile(positionRecollected!);
            print("Location saved to file!");
          }
        });
      },
    );
  }

  void _recordPositionToJson() {
    listenToLocationChanges();
    captureLocation();
    setState(() {
      statusRecording = !statusRecording;
      showAnimationLocationTracking = !showAnimationLocationTracking;
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
                // color: Colors.red,
                child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Visibility(
                        visible: showAnimationLocationTracking,
                        child: Lottie.network(
                            'https://assets3.lottiefiles.com/packages/lf20_FtD13Z.json')))),
            Container(
                // color: Colors.yellow,
                child: Column(children: [
              const Text('Realtime LatLon:'),
              Text(currentPosition != null
                  ? 'Lat: ${currentPosition?.latitude}'
                  : 'no data'),
              Text(currentPosition != null
                  ? 'Lon: ${currentPosition?.longitude}'
                  : 'no data'),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.rocket_launch,
                  color: Colors.blue,
                  size: 24.0,
                  semanticLabel: 'Start recording location tracking',
                ),
                TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: _recordPositionToJson,
                    child: Text(statusRecording ? 'Stop' : 'Start'))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.delete,
                  color: Colors.orange,
                  size: 24.0,
                  semanticLabel: 'Erase recorded data',
                ),
                TextButton(
                    onPressed: () =>
                        {_eraseData(), positionRecollected?.clear()},
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.orange),
                    ),
                    child: Text("Erase data"))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.data_array_rounded,
                  color: Colors.pink,
                  size: 24.0,
                  semanticLabel: 'View recorded data',
                ),
                TextButton(
                    onPressed: _goViewData,
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.pink),
                    ),
                    child: Text("View Data"))
              ]),
            ])),
            // Divider(),

            // showAnimationLocationTracking
            //     ? Lottie.network(
            //         'https://assets3.lottiefiles.com/packages/lf20_FtD13Z.json')
            //     : null

            // Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            //   Text('hola'),
            // ])
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: _requestLocationServicePermissions,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PositionInterface {
  int? timestamp;
  double? latitude;
  double? longitude;

  @override
  String toString() {
    return toJson().toString();
  }

  Map toJson() =>
      {'timestamp': timestamp, 'latitude': latitude, 'longitude': longitude};
}

class DataHome extends StatefulWidget {
  const DataHome({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<DataHome> createState() => _DataHomeState();
}

class _DataHomeState extends State<DataHome> {
  String toShow = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _readFile().then((value) => setState(() {
          toShow = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      // body: const Center(
      //   child: Text(toShow, style: TextStyle(fontSize: 24.0)),
      // ),

      body: SingleChildScrollView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // const Text(
            //   'You have pushed the button this many times:',
            // ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),

            Text(toShow)
            // Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            //   Text('hola'),
            // ])
          ],
        ),
      ),
    );
  }
}
