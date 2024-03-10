import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer audioPlayer;
  SoundService() : audioPlayer = AudioPlayer();

  playCorrectSound() async {
    try {
      await audioPlayer.stop();
      await audioPlayer.play(AssetSource('sound/WinSoundEffect.mp3'));
    } catch (e) {
      print('Error while playing WinSoundEffect.mp3: $e');
    }
  }

  playErrorSound() async {
    try {
      await audioPlayer.stop();
      await audioPlayer.play(AssetSource('sound/ErrorSoundEffect.mp3'));
    } catch (e) {
      print('Error while playing ErrorSoundEffect.mp3: $e');
    }
  }
}


