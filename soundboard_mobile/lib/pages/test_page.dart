import 'package:flutter/material.dart';
import 'package:soundboard_mobile/classes/server.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String message = "";
  late Server server = Server();

  @override
  void initState() {
    super.initState();
    server.serverInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(),
          spacer(),
          ElevatedButton(
            onPressed: () {
              server.sendMessage("Almafa");
            },
            child: const Text("Send message."),
          ),
          spacer(),
          StreamBuilder(
            stream: server.getStream(),
            builder: (context, snapshot) {
              message += "${snapshot.data ?? ""}\n";
              return Text(message);
            },
          )
        ],
      ),
    );
  }

  Widget spacer() {
    return const SizedBox(
      height: 20,
    );
  }
}
