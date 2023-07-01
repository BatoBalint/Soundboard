import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class Server {
  late Socket _server;
  final StreamController<String> _messaging = StreamController();
  final List<String> _addresses = [];
  final int _port = 2929;
  bool connectedToServer = false;
  Function asd = (Widget w) {};

  Stream<String> getStream() {
    return _messaging.stream;
  }

  Future<void> connectToServer() async {
    if (connectedToServer) return;
    String? data = await NetworkInfo().getWifiGatewayIP();
    data ?? "";
    String address = data!.substring(0, data.lastIndexOf("."));
    List<Future<bool>> futureList = [];
    for (int i = 1; i < 255; ++i) {
      futureList.add(tryConnection("$address.$i", _port));
    }
    await Future.wait(futureList);
    if (_addresses.isNotEmpty) {
      _server = await Socket.connect(_addresses[0], 2929);
      _server.listen((event) => _handleReceivedData(event));
      connectedToServer = true;
    }
  }

  Future<bool> tryConnection(String address, int port) async {
    try {
      Socket s = await Socket.connect(address, port,
          timeout: const Duration(seconds: 2));
      _addresses.add(address);
      _messaging.sink.add("Found server at: $address:$port");
      await s.close();
      s.destroy();
      return true;
    } catch (ex) {
      return false;
    }
  }

  Future<void> disconnectFromServer() async {
    if (connectedToServer) {
      await _server.flush();
      await _server.close();
      _server.destroy();
      _messaging.sink.add("Disconnected from the server.");
      connectedToServer = false;
    }
  }

  void setFunction(Function f) {
    asd = f;
  }

  void _handleReceivedData(Uint8List data) {
    Map<String, dynamic> map = jsonDecode(String.fromCharCodes(data));

    Image i = Image.memory(toUint8List(map["image"]));
    asd(i);
  }

  Uint8List toUint8List(List<dynamic> dynamicList) {
    List<int> myList = dynamicList.map((e) => e as int).toList();
    return Uint8List.fromList(myList);
  }

  void sendMessage(String message) {
    if (connectedToServer) {
      _server.write(message);
    }
  }
}
