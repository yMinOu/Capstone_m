/// 스플래시 영상 재생 후 AuthGate로 이동하는 화면
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:nihongo/features/auth/presentation/widgets/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/splash/splash.mp4',
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.play();

        _controller.addListener(() {
          final isFinished =
              _controller.value.position >= _controller.value.duration;

          if (isFinished && !_navigated) {
            _navigated = true;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AuthGate(),
              ),
            );
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.value.isInitialized
          ? SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      )
          : const SizedBox.expand()
    );
  }
}