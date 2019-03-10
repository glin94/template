import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:darulfikr/model/article.dart';
import 'package:flutter/services.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:darulfikr/resources/repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/date_symbol_data_local.dart' as intl;
import 'package:html/parser.dart' as parse;
import 'package:device_apps/device_apps.dart';

encode(Map map, String key) => map[key].toString().split(',').toList();
List<String> decode(List<dynamic> list) {
  var _list = list
      .map((f) => f['name'])
      .toString()
      .replaceAll("[", "")
      .replaceAll("]", "")
      .replaceAll("(", "")
      .replaceAll(")", "")
      .split(',')
      .toList();
  _list.removeWhere((s) => s.contains('...'));
  return _list;
}

List<String> decodeId(List<dynamic> list) {
  var _list = list
      .map((f) => f['id'])
      .toString()
      .replaceAll("[", "")
      .replaceAll("]", "")
      .replaceAll("(", "")
      .replaceAll(")", "")
      .split(',')
      .toList();
  _list.removeWhere((s) => s.contains('...'));
  return _list;
}

Center buildBadError() {
  return Center(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Icon(Icons.mood_bad, size: 50),
      Text(
        "Произошла неизвестная ошибка\nВозможно отсутствует соединение с интернетом",
        textAlign: TextAlign.center,
      )
    ],
  ));
}

String htmlEnescape(String s) {
  var unescape = new HtmlUnescape();
  var text = unescape.convert(s);
  return text;
}

void launchURL(String s) async {
  if (await canLaunch(s)) {
    await launch(s);
  } else {
    throw 'Could not launch $s';
  }
}

String articleInfo(Article artcle) {
  if (artcle.video.isNotEmpty) {
    return 'Видео';
  } else if (artcle.audio.isNotEmpty) {
    return 'Aудио';
  }
  if (artcle.book.isNotEmpty) {
    return 'Книга';
  } else
    return '';
}

void playYoutubeVideoByUrl(String video) async {
  bool isInstalled =
      await DeviceApps.isAppInstalled('com.google.android.youtube');
  isInstalled
      ? FlutterYoutube.playYoutubeVideoByUrl(
          apiKey: "AIzaSyAj0leitKBXcRwku17Gtu7xZoS-x0F66Kg",
          videoUrl: "https://www.youtube.com/embed/$video",
        )
      : launchURL("https://www.youtube.com/embed/$video");
}

String toDB(List<String> list) =>
    list.toString().replaceAll("[", "").replaceAll("]", "");

List<String> fromDB(String s) =>
    s.replaceAll("[", "").replaceAll("]", "").split(',').toList();
shareTo(BuildContext context, Article article) {
  final RenderBox box = context.findRenderObject();
  Share.share(
      "Даруль-Фикр.Ру - Исламский образовательный портал\n «" +
          article.title +
          "»\n " +
          article.url +
          "\n",
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
}

void initTimeLang() {
  timeago.setLocaleMessages("ru", timeago.RuMessages());
  var rus = intl.initializeDateFormatting("ru", null);
  Future.wait([rus]);
}

String parsedTimeForPlayer(int s) {
  DateTime date = new DateTime.fromMillisecondsSinceEpoch(s * 1000);
  var time = DateFormat("ms");
  return time.format(date);
}

String parseDate(String s) {
  s.replaceAll("T", " ");
  DateFormat format = new DateFormat("d MMMM, y", "ru");
  DateTime d = DateTime.parse(s);
  return format.format(d);
}

Future downloadBook(
    Article article, GlobalKey<ScaffoldState> scaffoldKey) async {
  {
    if (await canLaunch(article.book) || await canLaunch(article.audio)) {
      article.book.isNotEmpty
          ? await launch(article.book)
          : await launch(article.audio);
    } else {
      print(article.audio);

      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Ошибка скачивания!"),
      ));
    }
  }
}

void shareTimer(Article article, GlobalKey<ScaffoldState> scaffoldKey,
    BuildContext context) {
  Future.delayed(Duration(minutes: 3)).then((_) =>
      scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 10),
        content: Text(
          "Поделиться с другом?",
        ),
        action: SnackBarAction(
          label: "Да",
          onPressed: () {
            final RenderBox box = context.findRenderObject();
            Share.share(
                "Даруль Фикр «" + article.title + "»\n " + article.url + "\n",
                sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
          },
        ),
      )));
}

void showFootnote(url, scaffoldKey, article, context) {
  scaffoldKey.currentState.hideCurrentSnackBar();
  if (!url.toString().contains("ref")) {
    String name = url.replaceAll("#", "");
    var doc = parse.parseFragment(article.content);
    var e = doc
        .querySelectorAll("a[name]")
        .firstWhere((test) => test.attributes["name"] == name);
    scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 600),
      backgroundColor: Color(0xFF4b453f),
      content: SingleChildScrollView(
        child: InkWell(
          onLongPress: () =>
              Clipboard.setData(ClipboardData(text: e.parent.text)).then((_) {
                scaffoldKey.currentState.hideCurrentSnackBar();
                scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text("Скопировано"),
                ));
              }),
          child: Text(
            e.parent.text,
            style: Theme.of(context).textTheme.body1.copyWith(
                fontFamily: "PT Sans",
                height: 1.1,
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    ));
  }
}

showArticleMenu(
    BuildContext bContext,
    GlobalKey<ScaffoldState> scaffoldKey,
    Article article) {
  scaffoldKey.currentState.hideCurrentSnackBar();
  showModalBottomSheet(
      context: bContext,
      builder: (context) =>
          Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
                leading: Icon(Icons.share),
                title: Text('Поделиться'),
                onTap: () {
                  shareTo(context, article);
                }),
            ListTile(
              leading: Icon(
                  !article.isFavored ? Icons.bookmark_border : Icons.bookmark),
              title: Text(!article.isFavored
                  ? 'Добавить в избранное'
                  : 'Убрать из избранного'),
              onTap: () {
                article.isFavored = !article.isFavored;
                Navigator.pop(context);

                Repository.get().updateArticle(article);
                article.isFavored
                    ? scaffoldKey.currentState.showSnackBar(SnackBar(
                        content:
                            Text("«${article.title}» добавлено в Избранное"),
                        action: SnackBarAction(
                          label: "Отменить",
                          onPressed: () {
                            article.isFavored = false;
                            showArticleMenu(
                                bContext, scaffoldKey, article);
                          },
                        ),
                      ))
                    : Container();
              },
            )
          ]));
}

String parseDateAgo(String s) {
  s.replaceAll("T", " ");
  // DateFormat format = new DateFormat("d MMMM", "ru");
  DateTime d = DateTime.parse(s);
  return timeago.format(
    d,
    locale: "ru",
    allowFromNow: true,
  );
}
