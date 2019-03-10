import 'package:background_audio/background_audio.dart';
import 'package:darulfikr/ui/audio/player.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MiniPlayer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MiniPlayer({Key key, this.scaffoldKey}) : super(key: key);

  @override
  MiniPlayerState createState() {
    return new MiniPlayerState();
  }
}

class MiniPlayerState extends State<MiniPlayer> {
  String status = 'stopped';

  @override
  void initState() {
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

  stop() {
    BackgroundAudio.stop();
  }

  toggle() {
    BackgroundAudio.toggle();
  }

  play(BackgroundAudioPlaylist playlist, int index) async {
    await BackgroundAudio.setPlaylist(playlist);
    BackgroundAudio.play(index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListTile(
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlayerMix(
                      playlist: BackgroundAudio.playlist,
                      albumImage: BackgroundAudio.playlist.metadata['img'],
                    )),
          ),
      title: Text(
        BackgroundAudio.song['title'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        BackgroundAudio.song['author'],
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      leading: BackgroundAudio.playlist.metadata['img'] != null
          ? CachedNetworkImage( errorWidget: Image.asset(
                                      "assets/logo.jpg"
                                    ),
              width: 35,
              height: 35,
              fit: BoxFit.cover,
              imageUrl: BackgroundAudio.playlist.metadata['img'],
            )
          : Image.asset(
              "assets/logo.jpg",
              width: 35,
              fit: BoxFit.cover,
              height: 35,
            ),
      trailing: IconButton(
        icon: Icon(status == 'pause' ? Icons.play_arrow : Icons.pause),
        onPressed: () => toggle(),
      ),
    ));
  }
}
