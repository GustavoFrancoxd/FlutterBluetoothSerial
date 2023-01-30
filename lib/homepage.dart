import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.deviceAdress})
      : super(key: key);

  final String title;
  final String deviceAdress;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _bulbImgPathLivingRoom = "images/light_off.png";

  Color _clrButtonLivingRoom = Colors.green;

  String _txtButtonLivingRoom = "TURN ON";

  late BluetoothConnection connection;

  String _connectedYesNo = "Loading...";
  Color _colorConnectedYesNo = Colors.black;
  String _txtButtonCheckReload = "CHECK";

  _MyHomePageState();

  bool get isConnected => (connection.isConnected);

  Future<void> _connect() async {
    try {
      connection = await BluetoothConnection.toAddress(widget
          .deviceAdress); ///////////////////////////////////////////////////////////////
      Fluttertoast.showToast(
        msg: 'Connected to the bluetooth device',
      );
      print('Connected to the bluetooth device');
      setState(() {
        _connectedYesNo = "Connected.";
        _colorConnectedYesNo = Colors.green;
        _txtButtonCheckReload = "CHECK";
      });
    } catch (exception) {
      try {
        if (isConnected) {
          Fluttertoast.showToast(
            msg: 'Already connected to the device',
          );
          print('Already connected to the device');
          setState(() {
            _connectedYesNo = "Connected.";
            _colorConnectedYesNo = Colors.green;
            _txtButtonCheckReload = "CHECK";
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Cannot connect, exception occured',
          );
          print('Cannot connect, exception occured');
          setState(() {
            _connectedYesNo = "Not connected!";
            _colorConnectedYesNo = Colors.red;
            _txtButtonCheckReload = "RELOAD";
          });
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Cannot connect, probably not initialized connection',
        );
        print('Cannot connect, probably not initialized connection');
        try {
          setState(() {
            _connectedYesNo = "Not connected!";
            _colorConnectedYesNo = Colors.red;
            _txtButtonCheckReload = "RELOAD";
          });
        } catch (e) {
          print('inicializando');
        }
      }
    }
  }

  void waitLoading() {
    setState(() {
      _connectedYesNo = "Loading...";
      _colorConnectedYesNo = Colors.black;
      _txtButtonCheckReload = "CHECK";
    });
  }

  void _reloadOrCheck() {
    waitLoading();
    _connect();
  }

  Future<void> _sendData(String data) async {
    connection.output
        .add(Uint8List.fromList(utf8.encode(data))); // Sending data
    await connection.output.allSent;
  }

  void _setLightOrLockState(String roomOrDoorType) {
    if (_connectedYesNo == "Connected.") {
      setState(() {
        if (roomOrDoorType == "Living Room") {
          if (_bulbImgPathLivingRoom == "images/light_off.png" &&
              _clrButtonLivingRoom == Colors.green &&
              _txtButtonLivingRoom == "TURN ON") {
            _bulbImgPathLivingRoom = "images/light_on.png";
            _clrButtonLivingRoom = Colors.red;
            _txtButtonLivingRoom = "TURN OFF";
            _sendData("1");
          } else {
            _bulbImgPathLivingRoom = "images/light_off.png";
            _clrButtonLivingRoom = Colors.green;
            _txtButtonLivingRoom = "TURN ON";
            _sendData("2");
          }
        }
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Cannot send data!\nYou are not connected.',
      );
    }
  }

  Widget _buildRow(String roomOrDoorType, String imagePath, Color clrButton,
      String txtButton) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            height: 50.0,
            width: 50.0,
          ),
          Expanded(
              child:
                  Text(roomOrDoorType, style: const TextStyle(fontSize: 20))),
          SizedBox(
            width: 100.0,
            child: ElevatedButton(
              onPressed: () {
                _setLightOrLockState(roomOrDoorType);
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(clrButton)),
              child: Text(
                txtButton,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildRow("Living Room", _bulbImgPathLivingRoom,
                  _clrButtonLivingRoom, _txtButtonLivingRoom),
              Container(
                margin:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                padding: const EdgeInsets.fromLTRB(45.0, 10.0, 50.0, 10.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlue[100],
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(_connectedYesNo,
                            style: TextStyle(
                                fontSize: 20, color: _colorConnectedYesNo))),
                    SizedBox(
                      width: 100.0,
                      child: ElevatedButton(
                        onPressed: _reloadOrCheck,
                        child: Text(
                          _txtButtonCheckReload,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
