import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);
  final Color _orangeCTA = const Color(0xFFFD761A);
  final Color _greenSuccess = const Color(0xFF22C55E);

  int _selectedTabIndex = 0;
  bool _isFullscreen = false;

  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/sample_course.mp4")
      ..addListener(() => setState(() {}))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Pengaturan Video", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.speed_rounded),
                title: const Text("Kecepatan Pemutaran"),
                trailing: const Text("Normal", style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  // Buka modal opsi kecepatan
                },
              ),
              ListTile(
                leading: const Icon(Icons.high_quality_rounded),
                title: const Text("Kualitas Video"),
                trailing: const Text("Otomatis (1080p)", style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Top Bar (Simple) ---
            if (!_isFullscreen)
              Container(
                height: 56,
                color: _primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "Memutar Video",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 48,
                    ), // Spacer agar judul tetap di tengah
                  ],
                ),
              ),

            // --- 2. Video Player Area ---
            if (_isFullscreen)
              Expanded(
                child: _buildVideoPlayer(),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildVideoPlayer(),
              ),

            // --- 3. Judul & Navigasi (Scrollable) ---
            if (!_isFullscreen)
              Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  // Info Video
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "1. Pengenalan Alat & K3",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mastering iPhone 13 Screen Repair > Modul 1",
                          style: TextStyle(
                            fontSize: 12,
                            color: _primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTabItem("Materi", 0),
                        _buildTabItem("Diskusi", 1),
                        _buildTabItem("Catatan", 2),
                      ],
                    ),
                  ),

                  // Playlist / List Materi
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildPlaylistItem(
                          "1. Pengenalan Alat & K3",
                          "15:30",
                          isActive: true,
                        ),
                        const Divider(height: 1, indent: 16),
                        _buildPlaylistItem(
                          "2. Keamanan Baterai",
                          "10:45",
                          isCompleted: true,
                        ),
                        const Divider(height: 1, indent: 16),
                        _buildPlaylistItem(
                          "3. Membuka Segel Layar",
                          "22:10",
                          isLocked: true,
                        ),
                      ],
                    ),
                  ),

                  // Navigasi Next/Prev
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: null, // Disabled state
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.skip_previous_rounded),
                            label: const Text("Sebelumnya"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Memutar materi selanjutnya..."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              _controller.seekTo(Duration.zero);
                              _controller.play();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: _primaryBlue, width: 1.5),
                              foregroundColor: _primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.skip_next_rounded),
                            label: const Text(
                              "Selanjutnya",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildVideoPlayer() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: _isInitialized
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _isInitialized 
                          ? VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: _orangeCTA,
                                backgroundColor: Colors.white30,
                                bufferedColor: Colors.white54,
                              ),
                            )
                          : LinearProgressIndicator(
                              value: 0,
                              color: _orangeCTA,
                              backgroundColor: Colors.white30,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            },
                            child: Icon(
                              _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(pos - const Duration(seconds: 10));
                            },
                            child: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(pos + const Duration(seconds: 10));
                            },
                            child: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isInitialized
                                ? "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}"
                                : "00:00 / 00:00",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showSettingsModal,
                            child: const Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _toggleFullscreen,
                            child: Icon(
                              _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? _primaryBlue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? _primaryBlue : _textGray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistItem(
    String title,
    String duration, {
    bool isActive = false,
    bool isCompleted = false,
    bool isLocked = false,
  }) {
    Color bgColor = isActive ? Colors.blue.shade50 : Colors.white;
    Color iconColor;
    IconData icon;

    if (isActive) {
      iconColor = _primaryBlue;
      icon = Icons.play_circle_fill_rounded;
    } else if (isCompleted) {
      iconColor = _greenSuccess;
      icon = Icons.check_circle_rounded;
    } else {
      iconColor = Colors.grey.shade400;
      icon = Icons.lock_rounded;
    }

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isLocked ? _textGray : _textDark,
              ),
            ),
          ),
          Text(
            duration,
            style: TextStyle(
              color: isActive ? _primaryBlue : _textGray,
              fontSize: 12,
              fontFamily: 'DM Mono',
            ),
          ),
        ],
      ),
    );
  }
}
