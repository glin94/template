import 'package:darulfikr/ui/fragments/divider.dart';
import 'package:darulfikr/ui/fragments/slider.dart';
import 'package:darulfikr/ui/fragments/social_media.dart';
import 'package:darulfikr/utils/constants.dart';
import 'package:darulfikr/utils/other.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:package_info/package_info.dart';
import 'package:launch_review/launch_review.dart';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() {
    return new SettingsState();
  }
}

class SettingsState extends State<Settings> {
  String appName = "Даруль Фикр";
  String version = "1.0.0";
  initAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      version = packageInfo.version;
    });
  }

  @override
  void initState() {
    super.initState();
    initAppInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Настройки"),
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            buildDarkMode(context),
            buildTrashSearchHistory(),
            buildeedBack(),
            buildProblemsApp(),
            DivideHeader(
              headerText: "Информация",
              widget: ArticleSlider(category: 45),
            ),
            DivideHeader(
              headerText: "Помощь проекту",
              widget: buildProjectHelper(context),
            ),
            SocialMedia(),
            buildAppInfo()
          ],
        ));
  }

  GestureDetector buildProjectHelper(BuildContext context) {
    return GestureDetector(
      onTap: () => launchURL("http://$siteUrl/pomoshh-proektu/"),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead,
        child: HtmlView(
          data: helpHTML,
        ),
      ),
    );
  }

  Widget buildProblemsApp() => ListTile(
      title: Text("Сообщить о проблеме"),
      leading: Icon(Icons.pan_tool),
      trailing: Icon(Icons.navigate_next),
      onTap: () {
        launchURL(
            "mailto:selamappstudio@gmail.com?subject=$appName&body=appVersion:$version");
      });

  Widget buildeedBack() => ListTile(
        leading: Icon(Icons.star),
        trailing: Icon(Icons.navigate_next),
        title: Text("Написать отзыв"),
        onTap: () => LaunchReview.launch(),
      );

  Widget buildAppInfo() {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(appName),
            Text("Версия приложения: $version"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("© 2009 - ${DateTime.now().year} "),
                GestureDetector(
                  onTap: () => launchURL(siteUrl),
                  child: Text(
                    siteUrl,
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  FutureBuilder<SharedPreferences> buildTrashSearchHistory() {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          if (snapshot.hasData) {
            List<String> list =
                (snapshot.data.getStringList(("searchList")) ?? []);
            return ListTile(
              leading: list.isNotEmpty
                  ? Icon(Icons.restore_from_trash)
                  : Icon(Icons.history),
              title: Text("История поиска"),
              subtitle: Text(list.isNotEmpty ? "Очистить" : 'Нет данных'),
              onTap: () {
                setState(() {
                  list.clear();
                  snapshot.data.setStringList("searchList", list);
                });
              },
            );
          } else
            return Container();
        });
  }

  ListTile buildDarkMode(BuildContext context) {
    return ListTile(
      leading: Theme.of(context).brightness == Brightness.dark
          ? Icon(Icons.brightness_3)
          : Icon(Icons.brightness_7),
      title: Text("Тема приложения"),
      subtitle: Text(Theme.of(context).brightness == Brightness.dark
          ? "Темная"
          : 'Светлая'),
      onTap: () => DynamicTheme.of(context).setBrightness(
          Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark),
    );
  }
}
