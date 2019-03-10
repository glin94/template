import 'package:equatable/equatable.dart';
import 'package:darulfikr/utils/other.dart';

class Article extends Equatable {
  String id,
      img,
      date,
      title,
      content,
      about,
      video,
      book,
      audio,
      url,
      relatedPosts;
  bool isFavored;

  List<String> authors, tags, categories, tagsId;
  Article(
      {this.id,
      this.tagsId,
      this.isFavored,
      this.relatedPosts,
      this.title,
      this.url,
      this.categories,
      this.authors,
      this.content,
      this.date,
      this.img,
      this.about,
      this.video,
      this.audio,
      this.book,
      this.tags});
  factory Article.fromJson(Map<String, dynamic> jsonArticle) {
    return Article(
        isFavored: false,
        title: jsonArticle['title']['rendered'],
        id: jsonArticle['id'].toString(),
        about: jsonArticle['excerpt']['rendered'],
        categories: decode(jsonArticle['categories']),
        img: jsonArticle['featured_image_large_url'],
        date: jsonArticle['date_gmt'],
        relatedPosts: jsonArticle['related_post_link'],
        content: jsonArticle['content']['rendered'],
        authors: decode(jsonArticle['co_author']),
        video: jsonArticle['video'],
        book: jsonArticle['book'],
        audio: jsonArticle['audio'],
        url: jsonArticle["link"],
        tagsId: decodeId(jsonArticle['tags']),
        tags: decode(jsonArticle['tags']));
  }
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['title'] = title;
    map["video"] = video ?? "";
    map["book"] = book ?? "";
    map["audio"] = audio ?? "";
    map["tags"] = toDB(tags);
    map["tagsId"] = toDB(tagsId);
    map["categories"] = toDB(categories);
    map['authors'] = toDB(authors);
    map['relatedPosts'] = relatedPosts;
    map['img'] = img;
    map['isFavored'] = isFavored;
    map['content'] = content;
    map['url'] = url;
    map['date'] = date;
    map['about'] = about;
    return map;
  }

  Article.fromDB(Map map)
      : id = map['id'].toString(),
        title = map['title'],
        img = map['img'],
        content = map['content'],
        url = map['url'],
        relatedPosts = map['relatedPosts'],
        date = map['date'],
        about = map['about'],
        isFavored = map['isFavored'] == 1 ? true : false,
        authors = fromDB(map['authors']),
        tags = fromDB(map['tags']),
        tagsId = fromDB(map['tagsId']),
        categories = fromDB(map['categories']),
        video = map['video'],
        book = map['book'],
        audio = map['audio'];

  @override
  String toString() => 'Article { id: $id }';
}
