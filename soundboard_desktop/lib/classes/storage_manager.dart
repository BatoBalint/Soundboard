import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:soundboard_desktop/classes/sound.dart';
import 'package:soundboard_desktop/classes/sound_settings.dart';

class StorageManager {
  Directory? _appDir;
  Future<void>? initFuture;

  StorageManager() {
    initFuture = initialize();
  }

  Future<void> initialize() async {
    Directory documents = await getApplicationDocumentsDirectory();
    _appDir =
        Directory("${documents.path}\\${GlobalSettings.applicationFolderName}");
  }

  Future<List<Sound>> readSavedSounds() async {
    List<Sound> soundList = [];
    await waitForInit();
    File json = await getSoundListJSON();
    String jsonAsString = await json.readAsString();

    if (jsonAsString.isEmpty) return soundList; // Json was just created

    Map<String, dynamic> map = jsonDecode(jsonAsString);

    if (map["sounds"] == null) return soundList; // No saved sounds

    for (var s in map["sounds"]) {
      soundList.add(
        Sound(
          soundName: s["name"] ?? "FailedToLoad",
          filepath: s["filepath"] ?? "",
          imagepath: s["imagepath"] ?? "",
        ),
      );
    }
    return soundList;
  }

  saveSounds(Sound? newSound) async {
    waitForInit();
    Map<String, dynamic> map = {
      "sounds": [],
    };
    List<Sound> sounds = Sound.sounds.values.toList();
    if (newSound != null) sounds.add(newSound);
    for (Sound sound in sounds) {
      map["sounds"].add(sound.toJSONObject());
    }

    File json = File("${_appDir!.path}\\sounds.json");
    try {
      if (!json.existsSync()) json.createSync();
    } finally {
      json.writeAsString(jsonEncode(map));
    }
  }

  Future<Sound?> createNewSound(String name, String path) async {
    await waitForInit();
    File file = File(path);
    Directory targetDir = Directory("${_appDir!.path}\\$name");
    if (!targetDir.existsSync()) {
      targetDir.create(recursive: false);
    }
    try {
      await file.copy(
        "${targetDir.path}\\${file.path.substring(file.path.lastIndexOf("\\") + 1, file.path.length)}",
      );
    } catch (ex) {
      return null;
    }
    Sound s = Sound(soundName: name, filepath: path);
    saveSounds(s);
    return s;
  }

  Future<File> getSoundListJSON() async {
    await waitForInit();
    File json = File("${_appDir!.path}\\sounds.json");
    if (!json.existsSync()) await json.create();
    return json;
  }

  waitForInit() async {
    if (initFuture != null) {
      await Future.wait([initFuture!]);
      initFuture = null;
    }
  }
}
