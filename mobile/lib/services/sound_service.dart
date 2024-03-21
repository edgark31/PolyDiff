import 'package:audioplayers/audioplayers.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/account.dart';

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

  playOnCorrectSound(Sound sound) async {
    final AssetSource soundSource = AssetSource(sound.path);
    try {
      await audioPlayer.stop();
      await audioPlayer.play(soundSource);
    } catch (error) {
      print(
          'Error while trying to play error sound $sound.name with $sound.name: $error');
    }
  }

  playOnErrorSound(Sound sound) async {
    final AssetSource soundSource = AssetSource(sound.path);
    try {
      await audioPlayer.stop();
      await audioPlayer.play(soundSource);
    } catch (error) {
      print(
          'Error while trying to play error sound $sound.name with $sound.name: $error');
    }
  }
}
