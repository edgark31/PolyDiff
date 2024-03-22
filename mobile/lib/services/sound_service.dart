import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/services/info_service.dart';

class SoundService extends ChangeNotifier {
  final InfoService infoService = Get.put(InfoService());
  final AudioPlayer audioPlayer;

  SoundService() : audioPlayer = AudioPlayer();

  playCorrectSound() async {
    playSound(infoService.onCorrectSound.path);
  }

  playErrorSound() async {
    playSound(infoService.onErrorSound.path);
  }

  playSound(String soundPath) async {
    final AssetSource soundSource = AssetSource(soundPath.substring(6));
    try {
      stopSound();
      await audioPlayer.play(soundSource);
    } catch (error) {
      print('Error while trying to play $soundPath: $error');
    }
  }

  stopSound() async {
    await audioPlayer.stop();
  }
}
