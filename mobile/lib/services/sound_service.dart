import 'package:audioplayers/audioplayers.dart';
import 'package:mobile/constants/app_constants.dart';

class SoundService {
  final AudioPlayer audioPlayer;
  final String correctSoundPath = DEFAULT_ON_CORRECT_SOUND_PATH_1;
  final String errorSoundPath = DEFAULT_ON_ERROR_SOUND_PATH_1;

  SoundService() : audioPlayer = AudioPlayer() {
    preloadSounds();
  }

  void preloadSounds() async {
    try {
      await audioPlayer.setSource(AssetSource(correctSoundPath));
      await audioPlayer.setSource(AssetSource(errorSoundPath));
      // Does load the file, but we're not playing it immediately.
    } catch (e) {
      print('Error preloading sound: $e');
    }
  }

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

  playOnCorrectSound(String soundId) async {
    final String soundPath = "sound/correct$soundId.mp3";
    final AssetSource soundSource = AssetSource(soundPath);
    try {
      await audioPlayer.stop();
      await audioPlayer.play(soundSource);
    } catch (error) {
      print(
          'Error while trying to play error sound $soundId with $soundPath: $error');
    }
  }

  playOnErrorSound(String soundId) async {
    final String soundPath = "sound/error$soundId.mp3";
    final AssetSource soundSource = AssetSource(soundPath);
    try {
      await audioPlayer.stop();
      await audioPlayer.play(soundSource);
    } catch (error) {
      print(
          'Error while trying to play error sound $soundId with $soundPath: $error');
    }
  }
}
