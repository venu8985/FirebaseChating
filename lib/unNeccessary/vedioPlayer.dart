import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  List<VideoPlayerController?>? _controllers;
  List<Future<void>>? _initializeVideoPlayerFutures;
  int _currentIndex = 0;
  double _progress = 0.0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controllers = [
      VideoPlayerController.asset('assets/audio/vedio1.mov'),
      VideoPlayerController.asset('assets/audio/vedio2.mp4'),
    ];

    _initializeVideoPlayerFutures = List.generate(
      _controllers!.length,
      (index) => _controllers![index]!.initialize(),
    );

    _controllers![_currentIndex]!.addListener(() {
      setState(() {
        _progress =
            _controllers![_currentIndex]!.value.position.inMilliseconds /
                _controllers![_currentIndex]!.value.duration!.inMilliseconds;
      });
    });
  }

  @override
  void dispose() {
    _controllers!.forEach((controller) {
      controller!.dispose();
    });
    super.dispose();
  }

  void _playPause() {
    setState(() {
      if (_controllers![_currentIndex]!.value.isPlaying) {
        _controllers![_currentIndex]!.pause();
      } else {
        _controllers![_currentIndex]!.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _rewind() {
    Duration newPosition =
        _controllers![_currentIndex]!.value.position - Duration(seconds: 10);
    _controllers![_currentIndex]!.seekTo(newPosition);
  }

  void _fastForward() {
    Duration newPosition =
        _controllers![_currentIndex]!.value.position + Duration(seconds: 10);
    _controllers![_currentIndex]!.seekTo(newPosition);
  }

  void _onProgressChanged(double value) {
    setState(() {
      _progress = value;
      final newPosition = Duration(
        milliseconds:
            (_controllers![_currentIndex]!.value.duration!.inMilliseconds *
                    _progress)
                .toInt(),
      );
      _controllers![_currentIndex]!.seekTo(newPosition);
    });
  }

  void _scrollUp() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _controllers!.length;
      _isPlaying = false;
      _controllers![_currentIndex]!.seekTo(Duration.zero);
      _controllers![_currentIndex]!.play();
    });
  }

  void _scrollDown() {
    setState(() {
      _currentIndex = (_currentIndex - 1) % _controllers!.length;
      _isPlaying = false;
      _controllers![_currentIndex]!.seekTo(Duration.zero);
      _controllers![_currentIndex]!.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _playPause,
        onVerticalDragUpdate: (details) {
          final dragDistance = details.primaryDelta!;

          // Define a threshold for the distance to trigger the transition
          if (dragDistance.abs() > 10) {
            if (dragDistance < 10) {
              _scrollUp();
            } else {
              _scrollDown();
            }
          }
        },
        child: Container(
          height: size.height,
          width: double.infinity,
          child: FutureBuilder(
            future: _initializeVideoPlayerFutures![_currentIndex],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: size.aspectRatio,
                      child: VideoPlayer(_controllers![_currentIndex]!),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 0,
                      left: 0,
                      child: Slider(
                        value: _progress,
                        onChanged: (newValue) {
                          setState(() {
                            _progress = newValue;
                            final newPosition = Duration(
                              milliseconds: (_controllers![_currentIndex]!
                                          .value
                                          .duration!
                                          .inMilliseconds *
                                      _progress)
                                  .toInt(),
                            );
                            _controllers![_currentIndex]!.seekTo(newPosition);
                          });
                        },
                      ),
                    ),
                    Positioned(
                      bottom: size.height / 2,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _playPause,
                              icon: Icon(
                                _controllers![_currentIndex]!.value.isPlaying
                                    ? null
                                    : Icons.play_arrow,
                                color: Colors.white.withOpacity(0.6),
                                size: 80,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
