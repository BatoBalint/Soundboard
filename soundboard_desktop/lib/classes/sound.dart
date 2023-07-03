import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard_desktop/classes/sound_settings.dart';

class Sound {
  static List<AudioPlayer> audioPlayers = [];
  static Map<String, Sound> sounds = {};

  late AudioPlayer _audioPlayer;
  final String? filepath;
  final String? imagepath;
  String soundName;
  StreamController<bool>? playerState;
  bool ableToPlay = false;
  double soundVolume;

  Future? loading;

  Sound({
    required this.soundName,
    this.filepath,
    this.imagepath,
    this.soundVolume = 1,
  }) {
    if (soundVolume > 1) {
      soundVolume = 1;
    } else if (soundVolume < 0) {
      soundVolume = 0;
    }
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(0.1);
    playerState = StreamController();
    loading = _loadAudio();
  }

  Future<void> _loadAudio() async {
    if (filepath == null || filepath!.isEmpty) return;
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      checkApplicationFolder(dir);
      await _audioPlayer.setSourceDeviceFile(filepath!);
      ableToPlay = true;
      audioPlayers.add(_audioPlayer);
    } catch (ex) {
      ableToPlay = false;
    }
    playerState!.sink.add(ableToPlay);
    loading = null;
  }

  void checkApplicationFolder(Directory docDir) {
    Directory dir = Directory(
        "${docDir.path}\\${GlobalSettings.applicationFolderName}\\$soundName");
    if (!dir.existsSync()) dir.createSync();
  }

  Stream<bool> getPlayerStateStream() {
    return playerState!.stream;
  }

  Future<void> play() async {
    if (!ableToPlay) return;
    checkSettings();
    if (GlobalSettings.restartSoundOnPlay) {
      await _audioPlayer.stop();
    }
    await _audioPlayer.resume();
  }

  void stop() {
    if (ableToPlay) _audioPlayer.stop();
  }

  static void stopAll() {
    for (var element in audioPlayers) {
      element.stop();
    }
  }

  void setVolume(double volume) {
    if (volume > 1) volume = 1;
    if (volume < 0) volume = 0;
    _audioPlayer.setVolume(volume);
  }

  void checkSettings() {
    setVolume(GlobalSettings.volume * soundVolume);
  }

  Map<String, dynamic>? toJSONObject() {
    if (filepath == null || filepath!.isEmpty) return null;
    return {
      "name": soundName,
      "filepath": filepath,
      "imagepath": imagepath ?? "",
    };
  }
}
