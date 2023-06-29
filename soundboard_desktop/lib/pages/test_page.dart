import 'package:flutter/material.dart';
import 'package:soundboard_desktop/classes/server.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Server server = Server();
  String messages = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          spacer(),
          Container(
            width: double.infinity,
          ),
          ElevatedButton(
            onPressed: startButtonClick,
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.green),
            ),
            child: const Text(
              "Start",
              style: TextStyle(color: Colors.white),
            ),
          ),
          spacer(),
          ElevatedButton(
            onPressed: stopButtonClick,
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.red),
            ),
            child: const Text(
              "Stop",
              style: TextStyle(color: Colors.white),
            ),
          ),
          StreamBuilder(
            stream: server.getMessageStream(),
            builder: (context, snapshot) {
              messages += "\n${snapshot.data ?? ""}";
              return Expanded(
                child: Text(messages),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget spacer() {
    return const SizedBox(
      height: 10,
    );
  }

  void startButtonClick() {
    server.startServer();
  }

  void stopButtonClick() {
    server.stopServer();
  }
}
