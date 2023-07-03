import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:soundboard_desktop/classes/sound.dart';

class Server {
  late final InternetAddress ipAddress;
  final int port = 2929;
  bool serverIsRunning = false;
  ServerSocket? _server;
  final List<Socket> clients = [];
  final StreamController<String> _messaging = StreamController();
  Future? waitFor;

  Future<void> _setAddress() async {
    var networkinterfaces = await NetworkInterface.list();
    if (networkinterfaces.isNotEmpty &&
        networkinterfaces[0].addresses.isNotEmpty) {
      ipAddress = InternetAddress(networkinterfaces[0].addresses[0].address);
    }
  }

  Future<void> startServer() async {
    await _setAddress();
    if (!serverIsRunning) {
      _server = await ServerSocket.bind(ipAddress, port);
      serverIsRunning = true;
      _messaging.sink.add("Server is running on: ${ipAddress.address}:$port");
      _server!.listen((client) {
        clients.add(client);
        _handleClient(client);
      });
    }
  }

  Future<void> stopServer() async {
    if (serverIsRunning) {
      _server!.close();
      serverIsRunning = false;
      _messaging.add("Server is stopped.");
    }
  }

  void _handleClient(Socket client) {
    _messaging.sink
        .add("Server: Client connected with port ${client.remotePort}");
    client.listen(
      (Uint8List data) => _handleReceivedData(data),
      onDone: () {
        _messaging.sink.add("Client left: ${client.remotePort}");
        clients.remove(client);
        client.close();
      },
    );
  }

  Future<void> _handleReceivedData(Uint8List data) async {
    String msg = String.fromCharCodes(data);
    Map<String, dynamic> map = jsonDecode(msg);

    if (map["clientAction"] == null) return;

    decideAction(map);
  }

  void decideAction(Map<String, dynamic> map) {
    switch (map["clientAction"]) {
      case "playSound":
        playSound(map["soundName"]);
        break;
      case "stopSounds":
        stopSounds();
        break;
      default:
    }
  }

  void playSound(String soundName) {
    Sound.sounds[soundName]?.play();
  }

  void stopSounds() {
    Sound.stopAll();
  }

  bool sendToClient(Object data, int index) {
    if (clients.length <= index) return false;
    clients[index].write(data);
    return true;
  }

  Stream<String> getMessageStream() {
    return _messaging.stream;
  }

  void dispose() async {
    _messaging.close();
  }
}
