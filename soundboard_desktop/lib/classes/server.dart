import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class Server {
  late final InternetAddress ip;
  final int port = 2929;
  bool serverIsRunning = false;
  ServerSocket? _server;
  final List<Socket> _clients = [];
  StreamController<String> messaging = StreamController();

  Server() {
    ip = InternetAddress("127.0.0.1");
  }

  Future<void> startServer() async {
    if (!serverIsRunning) {
      _server = await ServerSocket.bind(ip, port);
      serverIsRunning = true;
      messaging.sink.add("Server is running on: ${ip.address}:$port");
      _server!.listen((event) {
        _handleClient(event);
      });
    }
  }

  void _handleClient(Socket client) {
    client.listen(
      (Uint8List data) {
        String message = String.fromCharCodes(data);
        messaging.sink.add("Server: $message");
      },
      onDone: () {
        messaging.sink.add("Client left: ${client.port}");
        _clients.remove(client);
        client.close();
      },
    );
  }

  Future<void> stopServer() async {
    if (serverIsRunning) {
      _server!.close();
      serverIsRunning = false;
      messaging.add("Server is stopped.");
    }
  }

  Stream<String> getMessageStream() {
    return messaging.stream;
  }

  void dispose() async {
    messaging.close();
  }
}
