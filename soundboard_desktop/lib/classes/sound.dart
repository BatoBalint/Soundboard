import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard_desktop/classes/sound_settings.dart';

class Sound {
  final String applicationFolderName = "OrangeSoundboard";

  static List<AudioPlayer> audioPlayers = [];
  static Map<String, Sound> sounds = {};

  String soundName;
  late AudioPlayer _audioPlayer;
  final String? fileName;
  bool ableToPlay = false;
  StreamController<bool>? playerState;

  Sound({required this.soundName, this.fileName}) {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(0.1);
    playerState = StreamController();
    _loadAudio();
    sounds[soundName] = this;
  }

  Future<void> _loadAudio() async {
    if (fileName == null) return;
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      checkApplicationFolder(dir);
      await _audioPlayer.setSourceDeviceFile(
          "${dir.path}\\$applicationFolderName\\$fileName");
      ableToPlay = true;
      audioPlayers.add(_audioPlayer);
    } catch (ex) {
      ableToPlay = false;
    }
    playerState!.sink.add(ableToPlay);
  }

  void checkApplicationFolder(Directory docDir) {
    Directory dir = Directory("${docDir.path}\\$applicationFolderName");
    if (!dir.existsSync()) dir.createSync();
  }

  Stream<bool> getPlayerStateStream() {
    return playerState!.stream;
  }

  Future<void> play() async {
    if (!ableToPlay) return;
    checkSettings();
    if (SoundSettings.restartSoundOnPlay) {
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
    setVolume(SoundSettings.volume);
  }
}
