import 'package:background_audio/background_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:darulfikr/utils/other.dart';
import 'package:page_view_indicator/page_view_indicator.dart';

class PlayerMix extends StatefulWidget {
  final BackgroundAudioPlaylist playlist;
  final String albumImage;
  const PlayerMix({Key key, this.playlist, this.albumImage}) : super(key: key);
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<PlayerMix> {
  final pageIndexNotifier = ValueNotifier<int>(0);

  String status = 'stopped';
  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    BackgroundAudio.init().then((e) {
      setState(() {});

      if (BackgroundAudio.playlist != null) {
        if (BackgroundAudio.playing) {
          setState(() => status = 'play');
        } else {
          setState(() => status = 'pause');
        }
      }
    });

    BackgroundAudio.onTogglePlayback((bool playing) {
      setState(() => status = playing ? 'play' : 'pause');
    });

    BackgroundAudio.onDuration((int duration) {
      setState(() {});
    });

    BackgroundAudio.onPosition((int position) {
      setState(() {});
    });

    BackgroundAudio.onNext(() {
      setState(() {});
    });

    BackgroundAudio.onPrev(() {
      setState(() {});
    });

    BackgroundAudio.onSelect(() {
      print('notification selected');
    });

    BackgroundAudio.onStop(() {
      setState(() => status = 'stopped');
    });

    super.initState();
  }

  @override
  void dispose() {
    pageIndexNotifier.dispose();
    super.dispose();
  }

  stop() {
    BackgroundAudio.stop();
  }

  toggle() {
    BackgroundAudio.toggle();
  }

  play(BackgroundAudioPlaylist playlist, int index) async {
    await BackgroundAudio.setPlaylist(playlist);
    BackgroundAudio.play(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: new BoxDecoration(
      //     gradient: new LinearGradient(
      //         colors: [
      //       Theme.of(context).accentColor,
      //       Colors.white70,
      //     ],
      //         tileMode: TileMode.mirror,
      //         begin: Alignment.centerRight,
      //         end: new Alignment(-1.0, -1.0))),
      child: Scaffold(
          endDrawer: Drawer(
            child: buildList(BackgroundAudio.playlist),
          ),
          // backgroundColor: Colors.transparent,
          key: scaffoldkey,
          appBar: AppBar(
            elevation: 0.0,
            actions: <Widget>[
              IconButton(
                onPressed: () => scaffoldkey.currentState.isEndDrawerOpen
                    ? Navigator.pop(context)
                    : scaffoldkey.currentState.openEndDrawer(),
                icon: Icon(
                  Icons.menu,
                  // color: Colors.white,
                ),
              )
            ],
            title: Text(
              BackgroundAudio.playlist.metadata["name"],
              // style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: Stack(
              alignment: FractionalOffset.bottomCenter,
              children: <Widget>[
                Container(
                  child: PageView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: 2,
                    onPageChanged: (index) => pageIndexNotifier.value = index,
                    itemBuilder: (c, i) {
                      List<Widget> build = List();
                      build.add(buildPlayer(c));
                      build.add(buildInfo());
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: build[i],
                      );
                    },
                  ),
                ),
                _indicator(),
              ],
            ),
          )),
    );
  }

  PageViewIndicator _indicator() {
    return PageViewIndicator(
      pageIndexNotifier: pageIndexNotifier,
      length: 2,
      normalBuilder: (animationController) => Circle(
            size: 8.0,
            color: Colors.white70,
          ),
      highlightedBuilder: (animationController) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animationController,
              curve: Curves.ease,
            ),
            child: Circle(
              size: 12.0,
              color: Theme.of(context).accentColor,
            ),
          ),
    );
  }

  Widget buildPlayer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          height: 250,
          width: 250,
          child: Material(
            elevation: 10,
            child: Hero(
                tag: BackgroundAudio.playlist.metadata["name"],
                child: widget.albumImage != null
                    ? CachedNetworkImage( errorWidget: Image.asset(
                                      "assets/logo.jpg"
                                    ),
                        imageUrl: widget.albumImage,
                        fit: BoxFit.cover,
                        placeholder: Image.asset("assets/logo.jpg"))
                    : Image.asset("assets/logo.jpg")),
          ),
        ),
        Text(
          BackgroundAudio.song["title"],
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.title.copyWith(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold),
        ),
        Column(
          children: <Widget>[
            Container(
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      parsedTimeForPlayer(BackgroundAudio.position) +
                          " / " +
                          parsedTimeForPlayer(BackgroundAudio.duration),
                      style: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 20.0),
                    ),
                  ],
                )),
            // Container(
            //   width: 300,
            //   child: BackgroundAudio.position > BackgroundAudio.duration
            //       ? Container()
            //       : Slider(
            //           inactiveColor: Colors.white,
            //           onChanged: (val) {
            //             BackgroundAudio.seekTo(val.toInt());
            //           },
            //           activeColor: Theme.of(context).accentColor,
            //           value: BackgroundAudio.position.toDouble(),
            //           max: BackgroundAudio.duration.toDouble(),
            //         ),
            // ),
          ],
        ),
        Container(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                    size: 40.0,
                  ),
                  onPressed: () => BackgroundAudio.prev(),
                ),
                IconButton(
                    icon: Icon(Icons.replay_10, size: 30.0),
                    onPressed: () =>
                        BackgroundAudio.seekTo(BackgroundAudio.position - 10)),
                IconButton(
                  iconSize: 70,
                  icon: Icon(
                    status == 'pause'
                        ? Icons.play_circle_outline
                        : Icons.pause_circle_outline,
                  ),
                  onPressed: () => toggle(),
                ),
                IconButton(
                    icon: Icon(Icons.forward_10, size: 30.0),
                    onPressed: () =>
                        BackgroundAudio.seekTo(BackgroundAudio.position + 10)),
                IconButton(
                  icon: Icon(Icons.skip_next, size: 40.0),
                  onPressed: () => BackgroundAudio.next(),
                )
              ]),
        )
      ],
    );
  }

  Widget buildList(BackgroundAudioPlaylist playlist) => Container(
        // decoration:
        //  new BoxDecoration(
        //     color: Colors.purple,
        //     gradient: new LinearGradient(
        //         colors: [
        //           Theme.of(context).accentColor,
        //           Colors.white70,
        //         ],
        //         tileMode: TileMode.mirror,
        //         begin: Alignment.centerRight,
        //         end: new Alignment(-5.0, -3.0))),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: BackgroundAudio.playlist.songs.length,
          itemBuilder: (c, i) {
            return ListTile(
              title: Text(
                BackgroundAudio.playlist.songs[i]["title"],
                style: Theme.of(context).textTheme.title.copyWith(),
              ),
              leading: IconButton(
                icon: Icon(BackgroundAudio.index == i
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline),
                iconSize: 35.0,
                onPressed: () {
                  BackgroundAudio.index == i ? toggle() : play(playlist, i);
                },
              ),
            );
          },
        ),
      );

  Widget buildInfo() {
    return Container(
      height: 350.0,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(physics: BouncingScrollPhysics(), children: <Widget>[
            Text(
              BackgroundAudio.playlist.metadata["desc"],
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16.0, height: 1.2),
            ),
          ])),
    );
  }

  Container buildPlaylistDesc() {
    return Container(
        child: Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          BackgroundAudio.playlist.metadata["desc"],
          textAlign: TextAlign.justify,
        ),
      ),
    ));
  }

  SliverList buildPlayerList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (c, i) => Card(
              child: ListTile(
                title: Text(BackgroundAudio.playlist.songs[i]["title"]),
                leading: IconButton(
                  icon: Icon(BackgroundAudio.index == i
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline),
                  iconSize: 35.0,
                  onPressed: () {
                    play(widget.playlist, i);
                  },
                ),
              ),
            ),
        childCount: BackgroundAudio.playlist.songs.length,
      ),
    );
  }
}
