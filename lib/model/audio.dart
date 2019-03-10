class AudioCategory {
  int id;
  String desc, name, link, img;
  List<dynamic> audioList;
  AudioCategory(
      {this.link, this.id, this.name, this.audioList, this.desc, this.img});
  factory AudioCategory.fromJson(Map<String, dynamic> json) {
    return AudioCategory(
        name: json["name"] as String,
        desc: json["description"] as String,
        audioList: json["audio"] as List<dynamic>,
        link: json["link"] as String,
        id: json["id"] as int);
  }
}

class PlayerList {
  List<String> list, titles;
  String name, desc;
  int index, position;
  PlayerList(
      {this.name,
      this.desc,
      this.list,
      this.titles,
      this.index,
      this.position});
}
