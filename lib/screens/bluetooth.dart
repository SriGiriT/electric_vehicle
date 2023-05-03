import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:electric_vehicle/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/reusable_card.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  String tempp = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double mainBatteryCharge = 98;
  double backUpBatteryCharge = 98;
  double batteryTemperature = 35.4;
  double motorTemperature = 36.2;
  double current = 0.07;
  bool isCharging = false;
  @override
  void initState() {
    super.initState();
  }

  List<String> extractValues(String input) {
    List<String> values = [];
    List<String> val = ["%", "%", "*", "*", "A", "h", "", "", ""];
    int ind = 0;
    String varr = val[ind];
    for (int i = 0; i < input.length; i++) {
      if (input[i] == ':') {
        int endIndex = input.indexOf("$varr", i + 1);
        if (endIndex == -1) {
          values.add(input.substring(i + 1).trim());
          break;
        } else {
          String value = input.substring(i + 1, endIndex).trim();
          values.add(value);
          i = endIndex;
        }
        if (ind >= val.length) break;
        varr = val[++ind];
      }
    }
    return values;
  }

  late BluetoothConnection connection;
  bool isConnected = false;
  List<String> messages = [];

  Future<void> connectToDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String seleceddevice = prefs.getString('device') ?? "";
    BluetoothDevice selectedDevice = seleceddevice == ""
        ? await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DiscoveryPage(),
            ),
          )
        : BluetoothDevice(address: seleceddevice);
    // BluetoothDevice selectedDevice = await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => DiscoveryPage(),
    //   ),
    // );
    if (selectedDevice != null) {
      BluetoothConnection newConnection =
          await BluetoothConnection.toAddress(selectedDevice.address);
      prefs.setString('device', selectedDevice.address);
      setState(() {
        connection = newConnection;
        isConnected = true;
      });

      newConnection.input!.listen((Uint8List data) {
        setState(() {
          String inp = String.fromCharCodes(data);
          List<String> lines = inp.split(RegExp(r"\r\n|\r|\n"));
          // print(lines);
          tempp += inp;
          // print(inp);
          if (tempp.length > 146) {
            print(tempp);
            // print("|||" + tempp);
            List<String> lines = [
              "Main Battery Charge:",
              "Backup Battery Charge:",
              "Battery Temperature:",
              "Motor Temperature:",
              "Current:",
              "Charging Status:",
              "",
              "",
              ""
            ];
            List<String> values = extractValues(tempp);
            for (int i = 0; i < values.length; i++) {
              lines[i] += values[i];
            }
            print(lines);
            for (String line in lines) {
              List<String> parts = line.split(':');
              if (parts.length > 1) {
                String key = parts[0].trim();
                String value = parts[1].trim();
                switch (key) {
                  case "Main Battery Charge":
                    try {
                      mainBatteryCharge =
                          double.parse(value.replaceAll('%', ''));
                    } catch (error) {
                      print(error);
                      print(1);
                    }
                    break;
                  case "Backup Battery Charge":
                    try {
                      backUpBatteryCharge =
                          double.parse(value.replaceAll('%', ''));
                    } catch (error) {
                      print(error);
                      print(2);
                    }
                    break;
                  case "Battery Temperature":
                    try {
                      batteryTemperature = double.parse(
                          value.replaceAll('C', '').replaceAll('*', ''));
                    } catch (error) {
                      print(error);
                      print(3);
                    }
                    break;
                  case "Motor Temperature":
                    try {
                      motorTemperature = double.parse(
                          value.replaceAll('C', '').replaceAll('*', ''));
                    } catch (error) {
                      print(error);
                      print(4);
                    }
                    break;
                  case "Current":
                    try {
                      current = double.parse(value.replaceAll('A', ''));
                    } catch (error) {
                      print(error);
                      print(5);
                    }
                    break;
                  case "Charging Status":
                    try {
                      isCharging = value.length > 2 ? false : true;
                    } catch (error) {
                      print(error);
                      print(6);
                    }
                    break;
                  default:
                    // Handle unknown keys
                    break;
                }
              }
            }
            tempp = "";
          }
        });
      });

      // newConnection.input!.listen(null, onDone: () {
      //   setState(() {
      //     isConnected = false;
      //   });
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isConnected
        ? Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Color(0xFF0A0E21),
              title: Text('Electric Vehicle'),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    isCharging ? "Charging  " : "Not Charging  ",
                    style: TextStyle(
                        color: isCharging ? Colors.green : Colors.red),
                  ),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ReusableCard(
                          onPress: () {},
                          colour: kActiveCardColour,
                          cardChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Main Battery Charge',
                                style: kLabelTextStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    mainBatteryCharge.toString(),
                                    style: kNumberTextStyle,
                                  ),
                                  Text(
                                    "  %",
                                    style: kLabelTextStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ReusableCard(
                          onPress: () {},
                          colour: kActiveCardColour,
                          cardChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Backup Battery Charge',
                                style: kLabelTextStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    backUpBatteryCharge.toString(),
                                    style: kNumberTextStyle,
                                  ),
                                  Text(
                                    "  %",
                                    style: kLabelTextStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ReusableCard(
                          onPress: () {},
                          colour: kActiveCardColour,
                          cardChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Battery Temperature',
                                style: kLabelTextStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    batteryTemperature.toString(),
                                    style: kNumberTextStyle,
                                  ),
                                  Text(
                                    "  C",
                                    style: kLabelTextStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ReusableCard(
                          onPress: () {},
                          colour: kActiveCardColour,
                          cardChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Motor Temperature',
                                style: kLabelTextStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    motorTemperature.toString().substring(0, 4),
                                    style: kNumberTextStyle,
                                  ),
                                  Text(
                                    "  C",
                                    style: kLabelTextStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ReusableCard(
                          onPress: () {},
                          colour: kActiveCardColour,
                          cardChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Current',
                                style: kLabelTextStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    current.toString(),
                                    style: kNumberTextStyle,
                                  ),
                                  Text(
                                    "  A",
                                    style: kLabelTextStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Bluetooth Connection'),
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isConnected
                        ? Text('Connected')
                        : ElevatedButton(
                            onPressed: connectToDevice,
                            child: Text('Connect'),
                          ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text(messages[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class DiscoveryPage extends StatefulWidget {
  @override
  _DiscoveryPageState createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  List<BluetoothDevice> devices = [];

  void discoverDevices() async {
    FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
      setState(() {
        devices.add(device.device);
      });
    });
  }

  void cancelDiscovery() {
    FlutterBluetoothSerial.instance.cancelDiscovery();
  }

  void connectToDevice(BluetoothDevice? device) {
    if (device != null) {
      connectToDevice(device);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Devices'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: discoverDevices,
              child: Text('Discover Devices'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(devices[index].name ?? "unknown"),
                    subtitle: Text(devices[index].address),
                    onTap: () {
                      Navigator.of(context).pop(devices[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
