import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String _currentUrl = '';

  MyAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      
      _player.onPlayerStateChanged.listen((PlayerState state) {
        _isPlaying = state == PlayerState.playing;
        _broadcastState();
      });
    } catch (e) {
      debugPrint('AudioHandler initialization error: $e');
    }
  }

  void _broadcastState() {
    playbackState.add(PlaybackState(
      controls: [
        if (_isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.playPause,
        MediaAction.stop,
      },
      androidCompactActionIndices: const [0],
      processingState: AudioProcessingState.ready,
      playing: _isPlaying,
    ));
  }

  Future<void> setTrack(String title, String url, String category) async {
    _currentUrl = url;
    mediaItem.add(MediaItem(
      id: url,
      album: 'ZenFocus Calm',
      title: title,
      artist: category,
      duration: const Duration(minutes: 25), // Standard focus session length
    ));
    if (_isPlaying) {
      await play();
    }
  }

  @override
  Future<void> play() async {
    if (_currentUrl.isEmpty) return;
    try {
      await _player.play(UrlSource(_currentUrl));
    } catch (e) {
      debugPrint('AudioHandler play error: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('AudioHandler pause error: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('AudioHandler stop error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume);
    } catch (e) {
      debugPrint('AudioHandler setVolume error: $e');
    }
  }
}
