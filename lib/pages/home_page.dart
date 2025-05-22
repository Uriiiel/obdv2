import 'package:flutter/material.dart';
import 'package:obdv2/pages/dashboard/dashComb_page.dart';
import 'package:obdv2/pages/dashboard/dashOx_page.dart';
import 'package:obdv2/pages/dashboard/dashboard_page.dart';
import 'package:obdv2/pages/infovin.dart';
import 'package:obdv2/pages/login_page.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

final Color colorPrimary = Color(0xFF000000);
final Color colorSecondary = Color(0xFF3F3F3F);

class HomePage extends StatefulWidget {
  final dynamic user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController =
          VideoPlayerController.asset("assets/images/caroblanco.mp4")
            ..setLooping(true)
            ..setPlaybackSpeed(1.5);

      await _videoController.initialize().timeout(Duration(seconds: 5));

      if (!mounted) return;

      setState(() {});

      _videoController.addListener(_videoListener);
      await _videoController.play();
    } on TimeoutException {
      print("Timeout inicializando video");
      if (mounted) setState(() {});
    } catch (e) {
      print("Video error: $e");
      if (mounted) setState(() {});
    }
  }

  void _videoListener() {
    if (_videoController.value.hasError) {
      print("Playback error: ${_videoController.value.errorDescription}");
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/carred.png',
              height: 150,
              width: 150,
              fit: BoxFit.contain,
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Monitoreo OBD',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 48),
          ],
        ),
        backgroundColor: Color(0xFF0166B3),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _videoController.value.isInitialized
                    ? SizedBox(
                        height: 190,
                        child: AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: [
                    _SensorButton(
                      gifAsset: 'assets/images/engranaje.gif',
                      label: 'Sensores del motor',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SpeedometerPage(user: widget.user),
                          ),
                        );
                      },
                    ),
                    _SensorButton(
                      gifAsset: 'assets/images/200w.gif',
                      label: 'Sensores de oxígeno',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DashboardOxPage(user: widget.user),
                          ),
                        );
                      },
                    ),
                    _SensorButton(
                      gifAsset: 'assets/images/gas.gif',
                      label: 'Sensores de combustible',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DashboardCombPage(user: widget.user),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFFFFFFFF),
    );
  }
}

class _SensorButton extends StatefulWidget {
  final String gifAsset;
  final String label;
  final VoidCallback onTap;

  const _SensorButton({
    required this.gifAsset,
    required this.label,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  __SensorButtonState createState() => __SensorButtonState();
}

class __SensorButtonState extends State<_SensorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 300,
            maxWidth: 450,
            minHeight: 190,
          ),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF0166B3).withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        Color(0xFF0166B3).withOpacity(_animation.value * 0.8),
                    blurRadius: 15 * _animation.value,
                    spreadRadius: 2 * _animation.value,
                  ),
                  BoxShadow(
                    color:
                        Color(0xFFFFFFFF).withOpacity(_animation.value * 0.4),
                    blurRadius: 10 * _animation.value,
                    spreadRadius: 1 * _animation.value,
                  ),
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: Offset(2, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(_animation.value * 0.5),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF709DCE)
                              .withOpacity(_animation.value * 0.6),
                          blurRadius: 20 * _animation.value,
                          spreadRadius: 5 * _animation.value,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      widget.gifAsset,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color(0xFF0166B3)
                              .withOpacity(_animation.value * 0.8),
                          blurRadius: 10 * _animation.value,
                        ),
                        Shadow(
                          color:
                              Colors.white.withOpacity(_animation.value * 0.5),
                          blurRadius: 5 * _animation.value,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
