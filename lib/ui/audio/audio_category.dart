import 'dart:io';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:darulfikr/utils/constants.dart';
import 'package:darulfikr/utils/other.dart';
import 'package:flutter/material.dart';
import 'package:darulfikr/model/audio.dart';
import 'package:darulfikr/resources/repository.dart';
import 'package:background_audio/background_audio.dart';
import 'package:darulfikr/ui/audio/player.dart';

class AudioCategoryView extends StatefulWidget {
  @override
  _AudioCategoryViewState createState() => _AudioCategoryViewState();
}

class _AudioCategoryViewState extends State<AudioCategoryView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController =
        new TabController(vsync: this, length: audioCategory.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: audioCategory.length,
        child: Scaffold(
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: new Container(
              child: new SafeArea(
                child: Column(
                  children: <Widget>[
                    new TabBar(
                      isScrollable: true,
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: new BubbleTabIndicator(
                        indicatorHeight: 35.0,
                        indicatorColor: Theme.of(context).accentColor,
                        tabBarIndicatorSize: TabBarIndicatorSize.tab,
                      ),
                      tabs: audioCategory
                          .map<Tab>((f) => Tab(
                                text: f.keys.first,
                              ))
                          .toList(),
                      controller: _tabController,
                    ),
                  ],
                ),
              ),
            ),
          ), //категории аудио
          body: new TabBarView(
            controller: _tabController,
            children: audioCategory
                .map<Widget>((f) => Container(
                    child: Center(
                        child: FutureBuilder<List<AudioCategory>>(
                            future: Repository.get().getAudio(
                              f.values.first,
                            ),
                            builder: (c, s) {
                              switch (s.connectionState) {
                                case ConnectionState.none:
                                  return Text(
                                      'Возможно отсутсвует соединение с интернетом');
                                case ConnectionState.active:
                                case ConnectionState.waiting:
                                  return Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                  ));
                                case ConnectionState.done:
                                  if (s.hasError) return buildBadError();
                                  return new CategoryView(
                                    items: s.data,
                                  );
                              }
                            }))))
                .toList(),
          ),
        ));
  }
}

class CategoryView extends StatelessWidget {
  final List<AudioCategory> items;
  const CategoryView({
    Key key,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (c, i) {
          return Column(
            children: <Widget>[
              ExpansionTile(
                leading: FutureBuilder(
                    future: Repository.get().getAudioImage(items[i].link),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      items[i].img = snapshot.data;
                      return Container(
                        height: 50,
                        width: 50,
                        child: Material(
                          elevation: 4,
                          child: Hero(
                            tag: items[i].name,
                            child: snapshot.hasData
                                ? CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: snapshot.data,
                                    errorWidget: Image.asset(
                                      "assets/logo.jpg",
                                      width: 50,
                                      height: 50,
                                    ),
                                    placeholder: Image.asset(
                                      "assets/logo.jpg",
                                      width: 50,
                                      height: 50,
                                    ),
                                  )
                                : Image.asset(
                                    "assets/logo.jpg",
                                    width: 50,
                                    height: 50,
                                  ),
                          ),
                        ),
                      );
                    }),
                title: Text(items[i].name),
                children: <Widget>[
                  //аудиофайлы
                  new AudioListView(
                    category: items[i],
                  )
                ],
              ),
              Divider()
            ],
          );
        },
      ),
    );
  }
}

//аудиофайлы
class AudioListView extends StatefulWidget {
  final AudioCategory category;

  const AudioListView({Key key, this.category}) : super(key: key);

  @override
  AudioListViewState createState() {
    return new AudioListViewState();
  }
}

class AudioListViewState extends State<AudioListView> {
  BackgroundAudioPlaylist _playlist;

  String status = 'stopped';
  @override
  void initState() {
    _playlist = BackgroundAudioPlaylist(
        metadata: {
          "name": widget.category.name,
          "desc": widget.category.desc,
          "img": widget.category.img
        },
        songs: List<Map<String, dynamic>>.from(
            widget.category.audioList.reversed.toList()));
    _playlist.songs.forEach((f) {
      f["url"] = f["audio_link"];
      f["author"] = widget.category.name;
      f["title"] = f['title']
          .toString()
          .replaceRange(0, f["title"].toString().indexOf(".") + 1, "");
    });

    super.initState();
  }

  play(BackgroundAudioPlaylist playlist, int index) async {
    await BackgroundAudio.setPlaylist(playlist);
    BackgroundAudio.play(index);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.category.audioList.length,
      itemBuilder: (c, i) {
        return InkWell(
          onTap: () {
            if (Platform.isAndroid) {
              print(widget.category.img);
              print(_playlist.metadata['img']);
              openAndroidAudio(i, context);
            } else {
              launchURL(_playlist.songs[i]['url']);
            }
          },
          child: ListTile(
            title: Text(_playlist.songs[i]["title"]),
          ),
        );
      },
    );
  }

  void openAndroidAudio(int i, BuildContext context) {
    play(_playlist, i);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PlayerMix(
                  albumImage: widget.category.img,
                  playlist: _playlist,
                )));
  }
}
