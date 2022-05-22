import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

const int SAMPLE_RATE = 8000;
const int BLOCK_SIZE = 4096;

typedef Fn = void Function();

//final exampleAudioFilePath =
//   "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3";

class MySoundPlayer extends StatefulWidget {
  final String filePath;

  const MySoundPlayer({Key? key, required this.filePath}) : super(key: key);

  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MySoundPlayer> {
  final FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;
  double _mSubscriptionDuration = 0;
  Uint8List? _boumData;
  StreamSubscription? _mPlayerSubscription;
  int pos = 0;

  @override
  void initState() {
    super.initState();
    init().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
  }

  @override
  void dispose() {
    stopPlayer(_mPlayer);
    cancelPlayerSubscriptions();

    // Be careful : you must `close` the audio session when you have finished with it.
    _mPlayer.closePlayer();

    super.dispose();
  }

  void cancelPlayerSubscriptions() {
    if (_mPlayerSubscription != null) {
      _mPlayerSubscription!.cancel();
      _mPlayerSubscription = null;
    }
  }

  Future<void> init() async {
    await _mPlayer.openPlayer();
    _boumData = await getAssetData(widget.filePath);
    _mPlayerSubscription = _mPlayer.onProgress!.listen((e) {
      setState(() {
        pos = e.position.inMilliseconds;
      });
    });
  }

  Future<Uint8List> getAssetData(String path) async {
    //var asset = await rootBundle.load(path);
    File file = File(path);
    return file.readAsBytes();
  }

  // -------  Here is the code to playback  -----------------------

  void play(FlutterSoundPlayer? player) async {
    await player!.startPlayer(
        fromDataBuffer: _boumData,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  Future<void> stopPlayer(FlutterSoundPlayer player) async {
    await player.stopPlayer();
  }

  Future<void> setSubscriptionDuration(
      double d) async // v is between 0.0 and 2000 (milliseconds)
  {
    _mSubscriptionDuration = d;
    setState(() {});
    await _mPlayer.setSubscriptionDuration(
      Duration(milliseconds: d.floor()),
    );
  }

  // --------------------- UI -------------------

  Fn? getPlaybackFn(FlutterSoundPlayer? player) {
    if (!_mPlayerIsInited) {
      return null;
    }
    return player!.isStopped
        ? () {
            play(player);
          }
        : () {
            stopPlayer(player).then((value) => setState(() {}));
          };
  }

  @override
  Widget build(BuildContext context) {
//getDuration();

    Widget playerSection = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              child: Center(
                child: ElevatedButton(
                  onPressed: getPlaybackFn(_mPlayer),
                  child: Text(_mPlayer.isPlaying ? 'Stop' : 'Play'),
                ),
              ),
            ),
            Container(
              child: Slider(
                value: _mSubscriptionDuration,
                min: 0.0,
                max: 2000.0,
                onChanged: setSubscriptionDuration,
                //divisions: 100
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ],
    );

    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(7)),
        child: playerSection,
      ),
    );
  }
}
