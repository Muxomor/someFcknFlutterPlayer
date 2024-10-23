import 'dart:convert';

class Song {
  //song->json
  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'logo': logo,
      'file': file,
      'name': name,
    };
  }

//json->song
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      author: json['author'],
      logo: json['logo'],
      file: json['file'],
      name: json['name'],
    );
  }
// Override equality operator

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song &&
        other.name == name &&
        other.author == author &&
        other.logo == logo &&
        other.file == file;
  } // Override hashCode

  @override
  int get hashCode {
    return name.hashCode ^ author.hashCode ^ logo.hashCode ^ file.hashCode;
  }

//List<Song> в JSON
  String songsToJson(List<Song> songs) {
    List<Map<String, dynamic>> songsMap =
        songs.map((song) => song.toJson()).toList();
    return jsonEncode(songsMap);
  }

//JSON в List<Song>
  static List<Song> songsFromJson(String jsonString) {
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((item) => Song.fromJson(item)).toList();
  }

  String? author;
  String? logo;
  String? file;
  String? name;
  Song({
    this.author,
    this.logo,
    this.file,
    this.name,
  });
}
