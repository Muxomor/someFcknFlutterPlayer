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

//List<Song> в JSON
String songsToJson(List<Song> songs) {
  List<Map<String, dynamic>> songsMap = songs.map((song) => song.toJson()).toList();
  return jsonEncode(songsMap);
}

//JSON в List<Song>
List<Song> songsFromJson(String jsonString) {
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

 