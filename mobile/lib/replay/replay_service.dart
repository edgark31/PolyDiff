import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:mobile/services/services.dart';

class ReplayService extends ChangeNotifier {
  final GameRecordProvider _gameRecordProvider = Get.find();
  final ReplayImagesProvider _replayImagesProvider = Get.find();
  final ReplayPlayerProvider _replayPlayerProvider = Get.find();
  final GameAreaService _gameAreaService = Get.find();
  final SoundService _soundService = Get.find();
  final ImageCacheService _imageCacheService = Get.find();

  GameRecord _record = DEFAULT_GAME_RECORD;

  int _currentReplayIndex = 0;
  int _nDifferencesFound = 0;

  int _replayTimer = 0;
  double _replaySpeed = 1.0;
  bool _isEndGame = false;
  bool _isDifferenceFound = false;
  bool _isCheatMode = false;
  bool _hasCheatModeEnabled = false;

  // Canvas Images
  Future<void> loadInitialCanvas(BuildContext context) async {
    Future<CanvasModel> initialImages = ImageConverterService.fromImagesBase64(
        _record.game.original, _record.game.modified);
    _replayImagesProvider.currentCanvas = initialImages;
  }

  Future<void> preloadGameEventImages(BuildContext context) async {
    List<Future> preloadFutures = [];

    for (int i = 0; i < _record.gameEvents.length; i++) {
      final event = _record.gameEvents[i];
      if (event.modified != null &&
          event.modified!.isNotEmpty &&
          event.gameEvent == "Found") {
        String base64Data =
            ReplayImagesProvider.extractBase64Data(event.modified!) ?? "";
        if (base64Data.isNotEmpty) {
          // Prepare and cache image without awaiting
          _replayImagesProvider.convertToImageState(
              i, base64Data, event.isMainCanvas ?? false);

          print(
              "----- Preloading image GAME EVENT : CANVAS :${event.isMainCanvas}  & EVENT ${event.gameEvent} -----");

          String cacheKey = i.toString();
          print("**** Preloading image with cache key $cacheKey ****");

          preloadFutures.add(ImageCacheService()
              .decodeAndCacheBase64Image(base64Data, cacheKey));
        }
      }
    }

    // Wait for all futures to complete
    await Future.wait(preloadFutures);
  }
}
