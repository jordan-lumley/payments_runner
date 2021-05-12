import 'package:engine/helpers/socket-broker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payments Runner App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TextEditingController _hostIpController =
      TextEditingController(text: "192.168.100.81");

  TextEditingController _hostPortController =
      TextEditingController(text: "53000");

  bool _isHostConfigured = false;

  String _hostIp = "";
  String _hostPort = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payments runner"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Card(
              color: _isHostConfigured ? Colors.lightGreen : Colors.red,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Connection Status: ",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    _isHostConfigured
                        ? const Icon(
                            Icons.check_circle_outline,
                            size: 32,
                          )
                        : const Icon(
                            Icons.cancel_outlined,
                            size: 32,
                          ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 22,
            child: GridView.count(
              crossAxisCount: 10,
              padding: EdgeInsets.all(16),
              crossAxisSpacing: 6,
              children: [
                MaterialButton(
                  color: Colors.tealAccent,
                  onPressed: () async {
                    var pinPadSocket = SocketBroker.sockets.firstWhere(
                      (element) => element.host == _hostIpController.text,
                    );

                    await pinPadSocket.connect(onError: (err) {
                      print(err);
                      setState(() {
                        _isHostConfigured = false;
                      });
                    }, whenConnected: (socket) async {
                      socket.writeJson({"": "asdf"});
                    });
                  },
                  child: Text(
                    'Sale',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                MaterialButton(
                  color: Colors.tealAccent,
                  onPressed: () async {
                    var pinPadSocket = SocketBroker.sockets.firstWhere(
                      (element) => element.host == _hostIpController.text,
                    );

                    await pinPadSocket.connect(onError: (err) {
                      print(err);
                      setState(() {
                        _isHostConfigured = false;
                      });
                    }, whenConnected: (socket) async {
                      socket.writeJson({"": "asdf"});
                    });
                  },
                  child: Text(
                    'Refund',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Settings'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      TextFormField(
                        controller: _hostIpController,
                        decoration: InputDecoration(labelText: "Host IP"),
                      ),
                      TextFormField(
                        controller: _hostPortController,
                        decoration: InputDecoration(labelText: "Host PORT"),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Save'),
                    onPressed: () async {
                      SocketBroker.sockets.add(
                        SocketObject(
                          host: _hostIpController.text,
                          port: int.parse(_hostPortController.text),
                        ),
                      );

                      setState(() {
                        _isHostConfigured = true;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Open settings',
        child: Icon(Icons.settings),
      ),
    );
  }
}
