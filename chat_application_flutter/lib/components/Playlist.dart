class Playlist {
  final String playlistName;

  final String playlistLogo;

  final String playlistInJson;

  final String playlistDescription;

  final String? playlistId; // Optional, if editing an existing playlist

  Playlist({
    required this.playlistName,
    required this.playlistLogo,
    required this.playlistInJson,
    required this.playlistDescription,
    this.playlistId,
  });
}