import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:soundboard_desktop/classes/server.dart';
import 'package:soundboard_desktop/classes/sound.dart';
import 'package:soundboard_desktop/classes/storage_manager.dart';
import 'package:soundboard_desktop/widgets/sound_button.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  StorageManager sm = StorageManager();
  Server server = Server();
  String _deviceIpAddress = "";
  String errorMessage = "";

  List<Sound> sounds = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController fileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getIpAddress();
    loadSounds();
  }

  loadSounds() async {
    if (sounds.isEmpty) {
      sounds = await sm.readSavedSounds();
    } else {}
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
            Wrap(
              spacing: 20,
              runSpacing: 40,
              children: soundbuttons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget spacer({double width = 10, double height = 10}) {
    return SizedBox(
      height: height,
      width: width,
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

  void testButtonClick() async {}

  Widget addSoundButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(0),
        backgroundColor: const Color.fromARGB(255, 39, 110, 41),
      ),
      onPressed: () {
        addSoundButtonClicked();
      },
      child: SizedBox(
        width: 120,
        height: 120,
        child: Center(
          child: Container(
            alignment: Alignment.center,
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addSoundButtonClicked() async {
    titleController.text = "";
    fileController.text = "";
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return addSoundDialog();
      },
    );
  }

  Widget addSoundDialog() {
    double maxWidth = 800;
    errorMessage = "";
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      backgroundColor: const Color.fromARGB(230, 10, 13, 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: StatefulBuilder(
        builder: (context, ss) {
          return Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add a new sound",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  spacer(height: 30),
                  titleInput(ss),
                  soundLocationInput(ss),
                  errorText(errorMessage),
                  Expanded(
                    child: Container(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      spacer(width: 8),
                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.green),
                        ),
                        onPressed: () async {
                          await saveNewSound(ss);
                          if (mounted) Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Add",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget titleInput(Function ss) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Sound title"),
        spacer(height: 5),
        Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: TextField(
            onChanged: (value) {
              validateTitleInput(ss);
            },
            controller: titleController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              hintText: "Meowmeow",
              fillColor: Colors.white10,
              filled: true,
            ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        spacer(height: 30),
      ],
    );
  }

  Widget soundLocationInput(Function ss) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Sound location"),
        spacer(height: 5),
        Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: TextField(
            onChanged: (value) {
              validateFileInput(ss);
            },
            controller: fileController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Container(
                decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.white10))),
                child: IconButton(
                  onPressed: () {
                    selectFile();
                  },
                  icon: const Icon(Icons.insert_drive_file, size: 30),
                ),
              ),
              hintText: "C:\\Downloads\\Meow.mp3",
              fillColor: Colors.white10,
              filled: true,
            ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        spacer(height: 30),
      ],
    );
  }

  Widget errorText(String errorMessage) {
    return Text(
      errorMessage,
      style: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void selectFile() async {
    FilePickerResult? fpr = await FilePicker.platform
        .pickFiles(allowMultiple: false, allowedExtensions: ["mp3", "wav"]);
    if (fpr != null) {
      fileController.text = fpr.files[0].path.toString();
    }
  }

  Future<void> saveNewSound(ss) async {
    if (!validateTitleInput(ss) || !validateFileInput(ss)) return;

    Sound? newSound = await sm.createNewSound(
      titleController.text.trim(),
      fileController.text,
    );

    if (newSound == null) {
      ss(() {
        errorMessage = "Couldn't copy the sound to the application folder.";
      });
    } else {
      setState(() {
        sounds.add(newSound);
      });
    }
  }

  List<Widget> soundbuttons() {
    List<Widget> children = [
      addSoundButton(),
      SoundButton(
        title: "Stop",
        buttonFunction: () => Sound.stopAll(),
        buttonColor: const Color.fromARGB(255, 151, 29, 20),
        textColor: Colors.white,
        checkPlayerState: false,
      ),
    ];
    for (Sound sound in sounds) {
      children.add(SoundButton(
        title: sound.soundName,
        sound: sound,
        checkPlayerState: true,
      ));
    }
    return children;
  }

  bool validateTitleInput(Function ss) {
    String title = titleController.text.trim();

    if (title.isEmpty) {
      ss(() {
        errorMessage = "The sound title can not be empty.";
      });
      return false;
    }
    if (Sound.sounds.keys.contains(title)) {
      ss(() {
        errorMessage = "This sound title is already taken.";
      });
      return false;
    }

    ss(() {
      errorMessage = "";
    });
    return true;
  }

  bool validateFileInput(Function ss) {
    String filePath = fileController.text;
    if (filePath.isEmpty) {
      ss(() {
        errorMessage = "You have to select a file.";
      });
      return false;
    }
    if (!File(filePath).existsSync()) {
      ss(() {
        errorMessage = "This file can't be reached.";
      });
      return false;
    }

    ss(() {
      errorMessage = "";
    });
    return true;
  }
}
