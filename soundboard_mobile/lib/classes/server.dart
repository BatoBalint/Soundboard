import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class Server {
  late Socket _server;
  final StreamController<String> _messaging = StreamController();
  final String _address = "192.168.1.150";
  final int _port = 2929;
  bool connectedToServer = false;

  Stream<String> getStream() {
    return _messaging.stream;
  }

  Future<void> serverInit() async {
    _messaging.sink.add("Connecting to server");
    _server = await Socket.connect(
      _address,
      _port,
      timeout: const Duration(seconds: 5),
    );
    connectedToServer = true;
    _messaging.sink.add("Connceted to $_address:$_port");
    _server.listen((Uint8List data) {
      _messaging.sink.add(String.fromCharCodes(data));
    });
  }

  void sendMessage(String message) {
    if (connectedToServer) {
      _server.write(message);
    }
  }
}
