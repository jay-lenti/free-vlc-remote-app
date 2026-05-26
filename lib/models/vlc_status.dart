class VlcStatus {
  final String state;
  final int volume;
  final int time;
  final int length;
  final String title;
  final String artist;

  VlcStatus({
    required this.state,
    required this.volume,
    required this.time,
    required this.length,
    required this.title,
    required this.artist,
  });

  factory VlcStatus.fromJson(Map<String, dynamic> json) {
    final meta = json['information']?['category']?['meta'];
    return VlcStatus(
      state: json['state'] ?? 'stopped',
      volume: json['volume'] ?? 0,
      time: json['time'] ?? 0,
      length: json['length'] ?? 0,
      title: meta?['title'] ?? 'Unknown Title',
      artist: meta?['artist'] ?? 'Unknown Artist',
    );
  }

  bool get isPlaying => state == 'playing';
}
