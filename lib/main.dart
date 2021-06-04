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
      TextEditingController(text: "10.10.1.144");

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

  List _actions = [
    "SALE",
    "REFUND",
    "VOID",
    "PRINT_RECEIPT",
    "ISSUE_GIFT",
    "INQUIRE_GIFT",
    "UPDATE_RECEIPT_HEADER",
    "CLOSE_BATCH",
    "TIP"
  ];

  List _tenderTypes = ["CREDIT", "DEBIT", "GIFT", "EBT"];

  String? _currentAction;
  String? _currentTenderType;
  Map? _currentExtData;
  TextEditingController _amountController = TextEditingController();
  TextEditingController _refNumController = TextEditingController();
  TextEditingController _paymentTypeController = TextEditingController();
  TextEditingController _headerController = TextEditingController();
  bool _headersEnabled = false;
  List _headerList = [];

  _sendCommand() async {
    var amount = "0";
    if (_amountController.text != "") {
      amount = _amountController.text;
    }
    _currentExtData = {
      "amount": int.parse(amount),
      "refNum": _refNumController.text,
      "paymentType": _paymentTypeController.text,
      "enabled": _headersEnabled,
      "headers": [_headerController.text]
    };
    await SocketBroker(
            host: _hostIpController.text,
            port: int.parse(_hostPortController.text))
        .connect(onError: (err) {
      print(err);
    }, whenConnected: (socket) async {
      socket.writeJson(
        {
          "action": _currentAction,
          "tenderType": _currentTenderType,
          "extData": _currentExtData
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payments runner"),
      ),
      body: Column(
        children: [
          Card(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Action: "),
              DropdownButton(
                value: _currentAction,
                items: _actions.map((action) {
                  return new DropdownMenuItem<String>(
                    value: action,
                    child: new Text(action,
                        style: new TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String? val) {
                  setState(() {
                    _currentAction = val;
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Tender Type: "),
              DropdownButton(
                value: _currentTenderType,
                items: _tenderTypes.map((tenderType) {
                  return new DropdownMenuItem<String>(
                    value: tenderType,
                    child: new Text(tenderType,
                        style: new TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String? val) {
                  setState(() {
                    _currentTenderType = val;
                  });
                },
              ),
            ],
          ),
          SizedBox(
              child: TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
              ),
              width: 200),
          SizedBox(
              child: TextField(
                controller: _refNumController,
                decoration: InputDecoration(
                  labelText: 'Ref Num',
                ),
              ),
              width: 200),
          SizedBox(
              child: TextField(
                controller: _paymentTypeController,
                decoration: InputDecoration(
                  labelText: 'Payment Type',
                ),
              ),
              width: 200),
          SizedBox(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Headers Enabled"),
                    Switch(
                        onChanged: (val) {
                          setState(() {
                            _headersEnabled = val;
                          });
                        },
                        value: _headersEnabled)
                  ]),
              width: 200),
          SizedBox(
              child: TextField(
                controller: _headerController,
                decoration: InputDecoration(
                  labelText: 'Headers',
                ),
              ),
              width: 200),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  color: Colors.green[300],
                  onPressed: () async {
                    await _sendCommand();
                  },
                  child: Text(
                    'Send Command',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  color: Colors.red[300],
                  onPressed: () async {
                    await SocketBroker(
                            host: _hostIpController.text,
                            port: int.parse(_hostPortController.text))
                        .connect(onError: (err) {
                      print(err);
                    }, whenConnected: (socket) async {
                      socket.writeJson({"action": "CANCEL"});
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: MaterialButton(
          //     color: Colors.blue[300],
          //     onPressed: () async {
          //       await SocketBroker(
          //               host: _hostIpController.text,
          //               port: int.parse(_hostPortController.text))
          //           .connect(onError: (err) {
          //         print(err);
          //       }, whenConnected: (socket) async {
          //         socket.writeJson({"action": "TIP"});
          //       });
          //     },
          //     child: Text(
          //       'Show Tip',
          //       style: TextStyle(
          //         fontSize: 24,
          //       ),
          //     ),
          //   ),
          // ),
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
                      await SocketBroker(
                              host: _hostIpController.text,
                              port: int.parse(_hostPortController.text))
                          .connect(onError: (err) {
                        print(err);
                      }, whenConnected: (socket) async {
                        socket.writeJson({"action": ""});
                      });
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
