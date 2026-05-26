class PlaylistItem {
  final String id;
  final String name;
  final bool isCurrent;

  PlaylistItem({
    required this.id,
    required this.name,
    required this.isCurrent,
  });

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown Item',
      isCurrent: json['current'] == 'current',
    );
  }
}
