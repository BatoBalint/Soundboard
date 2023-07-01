import 'dart:convert';
import 'dart:math';

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
  Image img = Image.asset("assets/sadge.png");

  @override
  void initState() {
    super.initState();
    server.setFunction(setImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(),
          ElevatedButton(
            onPressed: () {
              server.connectToServer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text(
              "Connect",
              style: TextStyle(color: Colors.white),
            ),
          ),
          spacer(),
          ElevatedButton(
            onPressed: () {
              server.disconnectFromServer();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Disconnect",
              style: TextStyle(color: Colors.white),
            ),
          ),
          spacer(),
          ElevatedButton(
            onPressed: () {
              Map<String, dynamic> map = {
                "action": "playSound",
                "soundId": Random().nextInt(25),
              };
              server.sendMessage(jsonEncode(
                map,
              ));
            },
            child: const Text("Send message."),
          ),
          spacer(),
          img,
          spacer(),
          StreamBuilder(
            stream: server.getStream(),
            builder: (context, snapshot) {
              message += "${snapshot.data ?? ""}\n";
              return Text(message);
            },
          ),
        ],
      ),
    );
  }

  void setImage(Image img2) {
    setState(() {
      img = img2;
    });
  }

  Widget spacer() {
    return const SizedBox(
      height: 20,
    );
  }
}
