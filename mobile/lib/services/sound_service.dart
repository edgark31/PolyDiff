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

/* 
import 'package:audioplayers/audio_cache.dart';

class SoundService {
  static final SoundService _singleton = SoundService._internal();

  factory SoundService() {
    return _singleton;
  }

  SoundService._internal();

  late AudioCache _audioCache;

  Future<void> init() async {
    _audioCache = AudioCache(prefix: 'assets/sound/');
    await _audioCache.load('example_sound.mp3'); // Replace example_sound.mp3 with your actual sound file name
  }

  Future<void> playSound() async {
    await _audioCache.play('example_sound.mp3'); // Replace example_sound.mp3 with your actual sound file name
  }
}*/
