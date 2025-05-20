import 'package:flutter/material.dart';
import 'package:obdv2/pages/dashboard/dashComb_page.dart';
import 'package:obdv2/pages/dashboard/dashOx_page.dart';
import 'package:obdv2/pages/dashboard/dashboard_page.dart';
import 'package:obdv2/pages/infovin.dart';
import 'package:obdv2/pages/login_page.dart';
import 'package:video_player/video_player.dart';

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
    _videoController =
        VideoPlayerController.asset("assets/images/caritovideo.mp4")
          ..setLooping(true)
          ..setPlaybackSpeed(1.5)
          ..initialize().then((_) {
            setState(() {});
            _videoController.play();
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
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
        backgroundColor: colorPrimary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              print("Configuraciones del usuario: ${widget.user}");
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
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
      backgroundColor: Color(0xFF282728),
    );
  }
}

class _SensorButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 300,
        maxWidth: 450,
        minHeight: 190,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorSecondary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(2, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                gifAsset,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
