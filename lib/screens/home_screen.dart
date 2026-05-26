import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vlc_provider.dart';
import 'settings_screen.dart';
import 'playlist_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VLC Remote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlaylistScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<VlcProvider>(
        builder: (context, vlc, child) {
          if (!vlc.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Not Connected to VLC'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
          }

          final status = vlc.status;
          if (status == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Now Playing
                Text(
                  status.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  status.artist,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Seek Bar
                Slider(
                  value: status.time.toDouble(),
                  max: status.length.toDouble() > 0 ? status.length.toDouble() : 1.0,
                  onChanged: (value) {
                    vlc.seek(value.toInt());
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatTime(status.time)),
                      Text(_formatTime(status.length)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Transport Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: vlc.previous,
                    ),
                    IconButton(
                      iconSize: 64,
                      icon: Icon(status.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                      onPressed: vlc.togglePause,
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.skip_next),
                      onPressed: vlc.next,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.stop),
                  onPressed: vlc.stop,
                ),
                const SizedBox(height: 40),

                // Volume Slider
                Row(
                  children: [
                    IconButton(
                      icon: Icon(status.volume == 0 ? Icons.volume_off : Icons.volume_up),
                      onPressed: () {
                        if (status.volume > 0) {
                          vlc.setVolume(0);
                        } else {
                          vlc.setVolume(128); // Default to 50% on unmute
                        }
                      },
                    ),
                    Expanded(
                      child: Slider(
                        value: status.volume.toDouble(),
                        max: 512, // 200%
                        onChanged: (value) {
                          vlc.setVolume(value.toInt());
                        },
                      ),
                    ),
                  ],
                ),
                Text('Volume: ${(status.volume / 256 * 100).toInt()}%'),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final mins = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '$mins:${secs.toString().padLeft(2, '0')}';
    }
  }
}
