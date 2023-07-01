import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class Server {
  late final InternetAddress ipAddress;
  final int port = 2929;
  bool serverIsRunning = false;
  ServerSocket? _server;
  final List<Socket> clients = [];
  final StreamController<String> _messaging = StreamController();

  Server() {
    _setAddress();
  }

  Future<void> _setAddress() async {
    var networkinterfaces = await NetworkInterface.list();
    if (networkinterfaces.isNotEmpty &&
        networkinterfaces[0].addresses.isNotEmpty) {
      ipAddress = InternetAddress(networkinterfaces[0].addresses[0].address);
    }
  }

  Future<void> startServer() async {
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
    //Map<String, dynamic> map = jsonDecode(msg);

    _messaging.sink.add("Client sent data. ($msg)");
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
