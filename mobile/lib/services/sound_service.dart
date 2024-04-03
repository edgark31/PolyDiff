import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/account.dart';

class SoundService extends ChangeNotifier {
  final AudioPlayer audioPlayer = AudioPlayer();
  final String correctSoundPath = "sound/correct1.mp3";
  final String errorSoundPath = "sound/error1.mp3";

  playCorrectSound() async {
    playSound(correctSoundPath);
  }

  playErrorSound() async {
    playSound(errorSoundPath);
  }

  playSound(String soundPath) async {
    final AssetSource soundSource = AssetSource(soundPath);
    try {
      await audioPlayer.stop();
      await audioPlayer.play(soundSource);
    } catch (error) {
      print('Error while trying to play $soundPath: $error');
    }
  }

  playOnCorrectSound(Sound sound) async {
    final AssetSource soundSource = AssetSource(sound.path.substring(6));
    try {
      await audioPlayer.stop();
      await audioPlayer.play(soundSource);
    } catch (error) {
      print(
          'Error while trying to play error sound $sound.name with $sound $error');
    }
  }

  playOnErrorSound(Sound sound) async {
    final AssetSource soundSource = AssetSource(sound.path.substring(6));
    try {
      await audioPlayer.stop();
      await audioPlayer.play(soundSource);
    } catch (error) {
      print(
          'Error while trying to play error sound $sound.name with $sound.name: $error');
    }
  }
}
