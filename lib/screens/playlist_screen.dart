import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vlc_provider.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VlcProvider>().refreshPlaylist());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlist')),
      body: Consumer<VlcProvider>(
        builder: (context, vlc, child) {
          if (vlc.playlist.isEmpty) {
            return const Center(child: Text('Playlist is empty or could not be loaded.'));
          }

          return ListView.builder(
            itemCount: vlc.playlist.length,
            itemBuilder: (context, index) {
              final item = vlc.playlist[index];
              return ListTile(
                title: Text(item.name),
                selected: item.isCurrent,
                trailing: item.isCurrent ? const Icon(Icons.play_arrow) : null,
                onTap: () {
                  vlc.playItem(item.id);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
