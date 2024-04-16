import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/models/account.dart';
import 'package:mobile/services/info_service.dart';

class SoundService extends ChangeNotifier {
  final AudioPlayer audioPlayer = AudioPlayer();
  final InfoService infoService = Get.find();

  playCorrectSound() async {
    playSound(infoService.onCorrectSound.path.replaceFirst('assets/', ''));
  }

  playErrorSound() async {
    playSound(infoService.onErrorSound.path.replaceFirst('assets/', ''));
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
    final AssetSource soundSource =
        AssetSource(sound.path.replaceFirst('assets/', ''));
    try {
      await audioPlayer.stop();
      await audioPlayer.play(soundSource);
    } catch (error) {
      print(
          'Error while trying to play error sound $sound.name with $sound $error');
    }
  }

  playOnErrorSound(Sound sound) async {
    final AssetSource soundSource =
        AssetSource(sound.path.replaceFirst('assets/', ''));
    try {
      await audioPlayer.stop();
      await audioPlayer.play(soundSource);
    } catch (error) {
      print(
          'Error while trying to play error sound $sound.name with $sound.name: $error');
    }
  }
}
