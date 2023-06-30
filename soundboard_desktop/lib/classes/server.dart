import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class Server {
  late final InternetAddress ip;
  final int port = 2929;
  bool serverIsRunning = false;
  ServerSocket? _server;
  final List<Socket> _clients = [];
  final StreamController<String> _messaging = StreamController();

  Server() {
    ip = InternetAddress("192.168.1.150");
  }

  Future<void> startServer() async {
    if (!serverIsRunning) {
      _server = await ServerSocket.bind(ip, port);
      serverIsRunning = true;
      _messaging.sink.add("Server is running on: ${ip.address}:$port");
      _server!.listen((event) {
        _handleClient(event);
      });
    }
  }

  void _handleClient(Socket client) {
    _messaging.sink
        .add("Server: Client connected with port ${client.remotePort}");
    client.listen(
      (Uint8List data) {
        String message = String.fromCharCodes(data);
        _messaging.sink.add("Server: $message");
      },
      onDone: () {
        _messaging.sink.add("Client left: ${client.remotePort}");
        _clients.remove(client);
        client.close();
      },
    );
  }

  Future<void> stopServer() async {
    if (serverIsRunning) {
      _server!.close();
      serverIsRunning = false;
      _messaging.add("Server is stopped.");
    }
  }

  Stream<String> getMessageStream() {
    return _messaging.stream;
  }

  void dispose() async {
    _messaging.close();
  }
}
