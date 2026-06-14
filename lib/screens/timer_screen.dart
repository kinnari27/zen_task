import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../main.dart'; // Imports the global audioHandler
import '../models/task.dart';
import '../models/focus_session.dart';

class TimerScreen extends StatefulWidget {
  final Task? task;
  final Function(FocusSession session, Task? updatedTask) onSessionComplete;

  const TimerScreen({
    super.key,
    this.task,
    required this.onSessionComplete,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  // Timer Duration (25 minutes Pomodoro)
  static const int _defaultSessionSeconds = 1500; 
  int _secondsRemaining = _defaultSessionSeconds;
  Timer? _timer;
  bool _isRunning = false;

  late String _selectedCategory;
  late String _sessionTitle;

  // Pulse animation for breathing guide
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Audio players configurations
  bool _isMuted = true; // Muted by default so it doesn't startle the user
  final double _volume = 0.5;
  int _selectedTrackIndex = 0;
  StreamSubscription<PlaybackState>? _playbackStateSubscription;

  final List<Map<String, String>> _tracks = [
    {
      'name': 'Zen Rain 🌧️',
      'url': 'https://assets.mixkit.co/active_storage/sfx/2433/2433-84.wav',
    },
    {
      'name': 'Forest Echoes 🌲',
      'url': 'https://assets.mixkit.co/active_storage/sfx/2568/2568-84.wav',
    },
    {
      'name': 'Tibetan Bowls 🥣',
      'url': 'https://assets.mixkit.co/active_storage/sfx/123/123-84.wav',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.task?.category ?? 'Work';
    _sessionTitle = widget.task?.title ?? 'General Focus Session';

    // Set up breathing animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4 seconds inhale/exhale cycles
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initAudio();
    _listenToPlaybackState();
  }

  void _listenToPlaybackState() {
    try {
      // Listen to OS audio controller state changes to synchronize countdown timer play/pause
      _playbackStateSubscription = audioHandler.playbackState.listen((PlaybackState state) {
        final bool playing = state.playing;
        if (playing != _isRunning) {
          _syncTimerWithAudio(playing);
        }
      });
    } catch (e) {
      debugPrint('Playback state subscription failed: $e');
    }
  }

  void _syncTimerWithAudio(bool playing) {
    if (playing) {
      if (!_isRunning) {
        setState(() {
          _isRunning = true;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_secondsRemaining > 0) {
            setState(() {
              _secondsRemaining--;
            });
          } else {
            _completeSession();
          }
        });
      }
    } else {
      if (_isRunning) {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  Future<void> _initAudio() async {
    try {
      final track = _tracks[_selectedTrackIndex];
      await audioHandler.setTrack(track['name']!, track['url']!, _selectedCategory);
      await audioHandler.setVolume(_isMuted ? 0.0 : _volume);
    } catch (e) {
      debugPrint('AudioPlayer initialization failed: $e');
    }
  }

  Future<void> _updateAudioPlayback() async {
    try {
      if (_isRunning && !_isMuted) {
        await audioHandler.setVolume(_volume);
        final track = _tracks[_selectedTrackIndex];
        await audioHandler.setTrack(track['name']!, track['url']!, _selectedCategory);
        await audioHandler.play();
      } else {
        await audioHandler.pause();
      }
    } catch (e) {
      debugPrint('AudioPlayer play/pause failed: $e');
    }
  }

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    try {
      if (_isMuted) {
        await audioHandler.setVolume(0.0);
        await audioHandler.pause();
      } else {
        await audioHandler.setVolume(_volume);
        if (_isRunning) {
          final track = _tracks[_selectedTrackIndex];
          await audioHandler.setTrack(track['name']!, track['url']!, _selectedCategory);
          await audioHandler.play();
        }
      }
    } catch (e) {
      debugPrint('AudioPlayer toggle mute failed: $e');
    }
  }

  Future<void> _changeTrack(int index) async {
    setState(() {
      _selectedTrackIndex = index;
    });
    try {
      final track = _tracks[index];
      await audioHandler.setTrack(track['name']!, track['url']!, _selectedCategory);
      if (_isRunning && !_isMuted) {
        await audioHandler.play();
      }
    } catch (e) {
      debugPrint('AudioPlayer track change failed: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _playbackStateSubscription?.cancel();
    try {
      audioHandler.stop();
    } catch (e) {
      debugPrint('AudioPlayer dispose stop failed: $e');
    }
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
      _updateAudioPlayback();
    } else {
      setState(() {
        _isRunning = true;
      });
      _updateAudioPlayback();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          _completeSession();
        }
      });
    }
  }

  void _completeSession() {
    _timer?.cancel();
    _isRunning = false;
    try {
      audioHandler.stop();
    } catch (e) {
      debugPrint('AudioPlayer stop failed: $e');
    }

    final actualFocusSeconds = _defaultSessionSeconds - _secondsRemaining;
    if (actualFocusSeconds <= 0) {
      Navigator.pop(context);
      return;
    }

    final focusSession = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: widget.task?.id,
      taskTitle: _sessionTitle,
      category: _selectedCategory,
      durationSeconds: actualFocusSeconds,
      timestamp: DateTime.now(),
    );

    Task? updatedTask;
    if (widget.task != null) {
      final isNowCompleted = (widget.task!.completedSessions + 1) >= widget.task!.estimatedSessions;
      updatedTask = widget.task!.copyWith(
        completedSessions: widget.task!.completedSessions + 1,
        focusSeconds: widget.task!.focusSeconds + actualFocusSeconds,
        isCompleted: isNowCompleted ? true : widget.task!.isCompleted,
      );
    }

    widget.onSessionComplete(focusSession, updatedTask);
    
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mindful Focus Session Complete! 🧘'),
          content: Text(
            'You focused on "$_sessionTitle" for ${(actualFocusSeconds / 60).round()} minutes. Feel free to take a break.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back home
              },
              child: const Text('Return to Stream'),
            ),
          ],
        );
      },
    );
  }

  void _confirmCancel() {
    if (_secondsRemaining == _defaultSessionSeconds) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Focus Session?'),
        content: const Text(
          'Would you like to record the time you have spent focusing so far?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close timer screen
            },
            child: const Text('Discard', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _completeSession();    // Record and exit
            },
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _secondsRemaining / _defaultSessionSeconds;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _confirmCancel,
        ),
        title: Text(widget.task != null ? 'Focus on Task' : 'Open Focus Stream'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              // Task / Session Info Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.task != null ? Icons.laptop_mac : Icons.self_improvement,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sessionTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Category: $_selectedCategory',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Timer dial wrapper with pulsing breathing guides
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 250 * _pulseAnimation.value,
                    height: 250 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: _isRunning ? 0.08 * _pulseAnimation.value : 0.02,
                          ),
                          blurRadius: 30,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: child,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 230,
                      height: 230,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.03),
                        color: theme.colorScheme.secondary,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_secondsRemaining),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isRunning ? 'INHALE • EXHALE' : 'PAUSED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),

              // Quick categories selector (if general session)
              if (widget.task == null) ...[
                const Text(
                  'Select focus category',
                  style: TextStyle(color: Colors.white30, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['Mind', 'Work', 'Health', 'Personal'].map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected && !_isRunning) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.black : Colors.white60,
                        ),
                        selectedColor: theme.colorScheme.secondary,
                        backgroundColor: theme.colorScheme.surface,
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
              ],

              // Controls Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel / Save progress
                  IconButton.filledTonal(
                    onPressed: _confirmCancel,
                    icon: const Icon(Icons.stop),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  
                  // Play / Pause
                  IconButton.filled(
                    onPressed: _toggleTimer,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(24),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  // Complete Session Early button (testing helper / override)
                  IconButton.filledTonal(
                    onPressed: _completeSession,
                    icon: const Icon(Icons.check),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      foregroundColor: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Calm Music Control Bar
              const Divider(color: Colors.white12, height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Calm Ambient Music',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
                      ),
                      Row(
                        children: [
                          Icon(
                            _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            size: 14,
                            color: _isMuted ? Colors.white30 : theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isMuted ? 'Muted' : 'Playing',
                            style: TextStyle(
                              fontSize: 11,
                              color: _isMuted ? Colors.white30 : theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Mute / Unmute Button
                      IconButton(
                        icon: Icon(_isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded),
                        onPressed: _toggleMute,
                        style: IconButton.styleFrom(
                          backgroundColor: _isMuted ? Colors.white.withValues(alpha: 0.03) : theme.colorScheme.secondary.withValues(alpha: 0.1),
                          foregroundColor: _isMuted ? Colors.white60 : theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Dropdown selector for Ambient tracks
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedTrackIndex,
                              isExpanded: true,
                              dropdownColor: theme.colorScheme.surface,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              items: List.generate(_tracks.length, (index) {
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(_tracks[index]['name']!),
                                );
                              }),
                              onChanged: (val) {
                                if (val != null) {
                                  _changeTrack(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
