import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:soundboard_desktop/classes/server.dart';
import 'package:soundboard_desktop/widgets/sound_button.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Server server = Server();
  String messages = "";
  String _deviceIpAddress = "";
  Image img = Image.asset("assets/szia.png");

  @override
  void initState() {
    super.initState();
    getIpAddress();
  }

  Future<void> getIpAddress() async {
    var networkinterfaces = await NetworkInterface.list();
    if (networkinterfaces.isNotEmpty &&
        networkinterfaces[0].addresses.isNotEmpty) {
      setState(() {
        _deviceIpAddress = networkinterfaces[0].addresses[0].address;
      });
    } else {
      setState(() {
        _deviceIpAddress = "N/A";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ip address: $_deviceIpAddress"),
                Row(
                  children: [
                    testButton(),
                    spacer(),
                    startButton(),
                    spacer(),
                    stopButton(),
                  ],
                ),
              ],
            ),
            spacer(),
            const Wrap(
              spacing: 20,
              runSpacing: 40,
              children: [
                SoundButton(title: "Muzsika", fileName: "test.mp3"),
                SoundButton(title: "Masodik"),
                SoundButton(title: "Harmadik"),
                SoundButton(title: "Negyedik"),
                SoundButton(title: "Otodik"),
                SoundButton(title: "Hatodik"),
                SoundButton(title: "Hetedik"),
                SoundButton(title: "Egy nagyon hosszu nevu sound"),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: StreamBuilder(
                  stream: server.getMessageStream(),
                  builder: (context, snapshot) {
                    messages += "\n${snapshot.data ?? ""}";
                    return SizedBox(
                      width: double.infinity,
                      child: Text(messages),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget spacer() {
    return const SizedBox(
      height: 10,
      width: 10,
    );
  }

  Widget startButton() {
    return ElevatedButton(
      onPressed: startButtonClick,
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Colors.green),
      ),
      child: const Text(
        "Start",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget stopButton() {
    return ElevatedButton(
      onPressed: stopButtonClick,
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Colors.red),
      ),
      child: const Text(
        "Stop",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void startButtonClick() {
    server.startServer();
  }

  void stopButtonClick() {
    server.stopServer();
  }

  Widget testButton() {
    return ElevatedButton(
      onPressed: testButtonClick,
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Colors.blue),
      ),
      child: const Text(
        "Test",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void testButtonClick() async {
    Uint8List myImage = await File("assets/szia.png").readAsBytes();
    Map<String, dynamic> map = {
      "image": myImage,
    };
    server.sendToClient(jsonEncode(map), 0);
  }
}
