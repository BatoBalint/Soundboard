import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class Sound {
  static List<AudioPlayer> audioPlayers = [];

  final String applicationFolderName = "OrangeSoundboard";
  final String? fileName;
  late AudioPlayer _audioPlayer;
  bool ableToPlay = false;
  String soundName;

  Sound({required this.soundName, this.fileName}) {
    _audioPlayer = AudioPlayer();
    _loadAudio(fileName);
  }

  Future<void> _loadAudio(String? fileName) async {
    if (fileName == null) return;
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      checkApplicationFolder(dir);
      _audioPlayer.setSourceDeviceFile(
          "${dir.path}\\$applicationFolderName\\$fileName");
      ableToPlay = true;
    } catch (ex) {
      ableToPlay = false;
    }
  }

  void checkApplicationFolder(Directory docDir) {
    Directory dir = Directory("${docDir.path}\\$applicationFolderName");
    if (!dir.existsSync()) dir.createSync();
  }

  Future<void> play(bool restart) async {
    if (!ableToPlay) return;

    if (restart) _audioPlayer.seek(Duration.zero);
    _audioPlayer.resume();
  }
}
