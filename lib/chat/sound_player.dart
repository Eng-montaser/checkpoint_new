// // import 'dart:async';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data' show Uint8List;
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:intl/intl.dart' show DateFormat;
//
// const int SAMPLE_RATE = 8000;
// const int BLOCK_SIZE = 4096;
//
// enum Media {
//   file,
//   buffer,
//   asset,
//   stream,
//   remoteExampleFile,
// }
//
// enum AudioState {
//   isPlaying,
//   isPaused,
//   isStopped,
//   isRecording,
//   isRecordingPaused,
// }
//
// //final exampleAudioFilePath =
// //   "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3";
//
// class MySoundPlayer extends StatefulWidget {
//   final String filePath;
//
//   const MySoundPlayer({Key key, this.filePath}) : super(key: key);
//
//   @override
//   MyAppState createState() => new MyAppState();
// }
//
// class MyAppState extends State<MySoundPlayer> {
//   bool _isRecording = false;
//   List<String> _path = [
//     null,
//     null,
//     null,
//     null,
//     null,
//     null,
//     null,
//     null,
//     null,
//     null,
//     null,
//     null,
//     null,
//     null,
//   ];
//   StreamSubscription _playerSubscription;
//
//   FlutterSoundPlayer playerModule = FlutterSoundPlayer();
//   FlutterSoundRecorder recorderModule = FlutterSoundRecorder();
//   String _playerTxt = '00:00:00';
//   double sliderCurrentPosition = 0.0;
//   double maxDuration = 1.0;
//   Media _media = Media.remoteExampleFile;
//   Codec _codec = Codec.aacADTS;
//
//   bool _encoderSupported = true; // Optimist
//   bool _decoderSupported = true; // Optimist
//   bool _isAudioPlayer = false;
//   double _duration = null;
//   IOSink sink;
//
//   Future<void> _initializeExample(bool withUI) async {
//     await playerModule.closeAudioSession();
//     _isAudioPlayer = withUI;
//     await playerModule.openAudioSession(
//         withUI: withUI,
//         focus: AudioFocus.requestFocusAndStopOthers,
//         category: SessionCategory.playAndRecord,
//         mode: SessionMode.modeDefault,
//         device: AudioDevice.speaker);
//     await playerModule.setSubscriptionDuration(Duration(milliseconds: 10));
//     await recorderModule.setSubscriptionDuration(Duration(milliseconds: 10));
//     initializeDateFormatting();
//     setCodec(_codec);
//   }
//
//   Future<void> init() async {
//     await recorderModule.openAudioSession(
//         focus: AudioFocus.requestFocusAndStopOthers,
//         category: SessionCategory.playAndRecord,
//         mode: SessionMode.modeDefault,
//         device: AudioDevice.speaker);
//     await _initializeExample(false);
//
//     if (Platform.isAndroid) {
//       // await copyAssets();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     init();
//     getDuration();
//   }
//
//   void cancelPlayerSubscriptions() {
//     if (_playerSubscription != null) {
//       _playerSubscription.cancel();
//       _playerSubscription = null;
//     }
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     cancelPlayerSubscriptions();
//     releaseFlauto();
//   }
//
//   Future<void> releaseFlauto() async {
//     try {
//       await playerModule.closeAudioSession();
//     } catch (e) {
//       //print('Released unsuccessful');
//       //print(e);
//     }
//   }
//
//   Future<void> getDuration() async {
//     if (await fileExists(widget.filePath)) {
//       Duration d = await flutterSoundHelper.duration(widget.filePath);
//
//       setState(() {
//         _duration = d != null ? d.inMilliseconds / 1000.0 : null;
//       });
//     }
//   }
//
//   Future<bool> fileExists(String path) async {
//     return await File(path).exists();
//   }
//
//   // In this simple example, we just load a file in memory.This is stupid but just for demonstration  of startPlayerFromBuffer()
//   Future<Uint8List> makeBuffer(String path) async {
//     try {
//       if (!await fileExists(path)) return null;
//       File file = File(path);
//       file.openRead();
//       var contents = await file.readAsBytes();
//       // //print('The file is ${contents.length} bytes long.');
//       return contents;
//     } catch (e) {
//       //print(e);
//       return null;
//     }
//   }
//
//   void _addListeners() {
//     cancelPlayerSubscriptions();
//     _playerSubscription = playerModule.onProgress.listen((e) {
//       if (e != null) {
//         maxDuration = e.duration.inMilliseconds.toDouble();
//         if (maxDuration <= 0) maxDuration = 0.0;
//
//         sliderCurrentPosition =
//             min(e.position.inMilliseconds.toDouble(), maxDuration);
//         if (sliderCurrentPosition < 0.0) {
//           sliderCurrentPosition = 0.0;
//         }
//
//         DateTime date = new DateTime.fromMillisecondsSinceEpoch(
//             e.position.inMilliseconds,
//             isUtc: true);
//         String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
//         this.setState(() {
//           this._playerTxt = txt.substring(0, 8);
//         });
//       }
//     });
//   }
//
//   Future<Uint8List> _readFileByte(String filePath) async {
//     Uri myUri = Uri.parse(filePath);
//     File audioFile = new File.fromUri(myUri);
//     Uint8List bytes;
//     await audioFile.readAsBytes().then((value) {
//       bytes = Uint8List.fromList(value);
//       //print('reading of bytes is completed');
//     });
//     return bytes;
//   }
//
//   Future<void> feedHim(String path) async {
//     Uint8List data = await _readFileByte(path);
//     return playerModule.feedFromStream(data);
//   }
//
//   Future<void> startPlayer() async {
//     getDuration();
//     try {
//       Uint8List dataBuffer;
//       String audioFilePath;
//       Codec codec = _codec;
//       if (_media == Media.remoteExampleFile) {
//         if (await fileExists(widget.filePath)) audioFilePath = widget.filePath;
//         // We have to play an example audio file loaded via a URL
//         audioFilePath = widget.filePath;
//       }
//
//       // Check whether the user wants to use the audio player features
//       if (_isAudioPlayer) {
//         String albumArtUrl;
//         String albumArtAsset;
//         String albumArtFile;
//
//         albumArtFile =
//             await playerModule.getResourcePath() + "/images/logo_only.png";
//         //  //print(albumArtFile);
//
//         final track = Track(
//           trackPath: audioFilePath,
//           codec: _codec,
//           dataBuffer: dataBuffer,
// //          trackTitle: "This is a record",
// //          trackAuthor: "from flutter_sound",
//           albumArtUrl: albumArtUrl,
//           albumArtAsset: albumArtAsset,
//           albumArtFile: albumArtFile,
//         );
//         await playerModule.startPlayerFromTrack(track,
//             defaultPauseResume: false,
//             removeUIWhenStopped: true, whenFinished: () {
//           //print('I hope you enjoyed listening to this song');
//           stopPlayer();
//           setState(() {});
//         }, onSkipBackward: () {
//           //print('Skip backward');
//           stopPlayer();
//           startPlayer();
//         }, onSkipForward: () {
//           //print('Skip forward');
//           stopPlayer();
//           startPlayer();
//         }, onPaused: (bool b) {
//           if (b)
//             playerModule.pausePlayer();
//           else
//             playerModule.resumePlayer();
//         });
//       } else {
//         if (audioFilePath != null) {
//           await playerModule.startPlayer(
//               fromURI: audioFilePath,
//               codec: codec,
//               sampleRate: SAMPLE_RATE,
//               whenFinished: () {
//                 print('Play1 finished');
//                 stopPlayer();
//                 setState(() {
//                   //   stopPlayer();
//                 });
//               });
//         }
//       }
//       _addListeners();
//       setState(() {});
//       //print('<--- startPlayer');
//     } catch (err) {
//       //print('error: $err');
//     }
//   }
//
//   Future<void> stopPlayer() async {
//     try {
//       await playerModule.stopPlayer();
//       //print('stopPlayer');
//       if (_playerSubscription != null) {
//         _playerSubscription.cancel();
//         _playerSubscription = null;
//       }
//       sliderCurrentPosition = 0.0;
//     } catch (err) {
//       //print('error: $err');
//     }
//     this.setState(() {});
//   }
//
//   void pauseResumePlayer() async {
//     if (playerModule.isPlaying) {
//       await playerModule.pausePlayer();
//     } else {
//       await playerModule.resumePlayer();
//     }
//     setState(() {});
//   }
//
//   void pauseResumeRecorder() async {
//     if (recorderModule.isPaused) {
//       await recorderModule.resumeRecorder();
//     } else {
//       await recorderModule.pauseRecorder();
//       assert(recorderModule.isPaused);
//     }
//     setState(() {});
//   }
//
//   void seekToPlayer(int milliSecs) async {
//     //print('-->seekToPlayer');
//     if (playerModule.isPlaying)
//       await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
//     //print('<--seekToPlayer');
//   }
//
//   void Function() onPauseResumePlayerPressed() {
//     if (playerModule == null) return null;
//     if (playerModule.isPaused || playerModule.isPlaying) {
//       return pauseResumePlayer;
//     }
//     return null;
//   }
//
//   void Function() onPauseResumeRecorderPressed() {
//     if (recorderModule == null) return null;
//     if (recorderModule.isPaused || recorderModule.isRecording) {
//       return pauseResumeRecorder;
//     }
//     return null;
//   }
//
//   void Function() onStopPlayerPressed() {
//     if (playerModule == null) return null;
//     return (playerModule.isPlaying || playerModule.isPaused)
//         ? stopPlayer
//         : null;
//   }
//
//   void Function() onStartPlayerPressed() {
//     if (playerModule == null) return null;
//     if (_media == Media.file ||
//         _media == Media.stream ||
//         _media == Media.buffer) // A file must be already recorded to play it
//     {
//       if (_path[_codec.index] == null) return null;
//     }
//     if (_media == Media.remoteExampleFile &&
//         _codec != Codec.mp3) // in this example we use just a remote mp3 file
//       return startPlayer;
//
//     if (_media == Media.stream && _codec != Codec.pcm16) return null;
//
//     if (_media == Media.stream && _isAudioPlayer) return null;
//
//     // Disable the button if the selected codec is not supported
//     if (!(_decoderSupported || _codec == Codec.pcm16)) return null;
//
//     return (playerModule.isStopped) ? startPlayer : null;
//   }
//
//   void setCodec(Codec codec) async {
//     _encoderSupported = await recorderModule.isEncoderSupported(codec);
//     _decoderSupported = await playerModule.isDecoderSupported(codec);
//
//     setState(() {
//       _codec = codec;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
// //getDuration();
//
//     Widget playerSection = Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         Row(
//           children: <Widget>[
//             Container(
//               child: Center(
//                 child: FloatingActionButton(
//                   clipBehavior: Clip.hardEdge,
//                   backgroundColor: Color(0xff293e52),
//                   elevation: 1,
//                   child: playerModule.isPlaying
//                       ? IconButton(
//                           icon: Icon(
//                             Icons.pause,
//                             color: Colors.white,
//                           ),
//                           onPressed: () => playerModule.pausePlayer(),
//                         )
//                       : IconButton(
//                           icon: Icon(
//                             Icons.play_arrow,
//                             color: Colors.white,
//                           ),
//                           onPressed: playerModule.isPaused
//                               ? playerModule.resumePlayer
//                               : startPlayer,
//                         ),
//                 ),
//               ),
//             ),
//             Container(
//                 child: Slider(
//                     value: min(sliderCurrentPosition, maxDuration),
//                     min: 0.0,
//                     max: maxDuration,
//                     activeColor: Color(0xff293e52),
//                     inactiveColor: Color(0xff293e52).withOpacity(.2),
//                     onChanged: (double value) async {
//                       await seekToPlayer(value.toInt());
//                     },
//                     divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt())),
//           ],
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//         ),
//         playerModule.isPlaying
//             ? Row(
//                 children: [
//                   Container(
//                     child: Text(
//                       this._playerTxt,
//                       style: TextStyle(
//                         fontSize: 14.0,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     //  height: 30.0,
//                     child: Text(_duration != null
//                         ? "/${_duration.round()} ${'sec.'.tr()}"
//                         : ''),
//                   ),
//                 ],
//               )
//             : Container(
//                 //  height: 30.0,
//                 child: Text(_duration != null
//                     ? "${_duration.round()} ${'sec.'.tr()}"
//                     : ''),
//               ),
//       ],
//     );
//
//     return Center(
//       child: Container(
//         decoration: BoxDecoration(
//             color: Colors.grey[200], borderRadius: BorderRadius.circular(7)),
//         child: playerSection,
//       ),
//     );
//   }
// }
//
// //import 'dart:async';
// //import 'dart:io';
// //import 'dart:math';
// //import 'dart:typed_data' show Uint8List;
// //
// //import 'package:easy_localization/easy_localization.dart';
// //import 'package:flutter/foundation.dart';
// //import 'package:flutter/material.dart';
// //import 'package:flutter_sound/flutter_sound.dart';
// //import 'package:intl/date_symbol_data_local.dart';
// //import 'package:intl/intl.dart' show DateFormat;
// //
// //const int SAMPLE_RATE = 8000;
// //const int BLOCK_SIZE = 4096;
// //
// //enum Media {
// //  file,
// //  buffer,
// //  asset,
// //  stream,
// //  remoteExampleFile,
// //}
// //enum AudioState {
// //  isPlaying,
// //  isPaused,
// //  isStopped,
// //  isRecording,
// //  isRecordingPaused,
// //}
// //
// ////final exampleAudioFilePath =
// ////   "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3";
// //
// //class MySoundPlayer extends StatefulWidget {
// //  final String filePath;
// //
// //  const MySoundPlayer({Key key, this.filePath}) : super(key: key);
// //
// //  @override
// //  MyAppState createState() => new MyAppState();
// //}
// //
// //class MyAppState extends State<MySoundPlayer> {
// //  List<String> _path = [
// //    null,
// //    null,
// //    null,
// //    null,
// //    null,
// //    null,
// //    null,
// //    null,
// //    null,
// //    null,
// //    null,
// //    null,
// //    null,
// //    null,
// //  ];
// //  StreamSubscription _playerSubscription;
// //
// //  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
// //  String _playerTxt = '00:00:00';
// //  double sliderCurrentPosition = 0.0;
// //  double maxDuration = 1.0;
// //  Media _media = Media.remoteExampleFile;
// //  Codec _codec = Codec.aacMP4;
// //
// //  bool _decoderSupported = true; // Optimist
// //  bool _isAudioPlayer = true;
// //  double _duration = null;
// //  IOSink sink;
// //
// //  Future<void> _initializeExample(bool withUI) async {
// //    await playerModule.closeAudioSession();
// //    _isAudioPlayer = withUI;
// //    await playerModule.openAudioSession(
// //        withUI: withUI,
// //        focus: AudioFocus.requestFocusAndStopOthers,
// //        category: SessionCategory.playAndRecord,
// //        mode: SessionMode.modeDefault,
// //        device: AudioDevice.speaker);
// //    await playerModule.setSubscriptionDuration(Duration(milliseconds: 10));
// //    initializeDateFormatting();
// //    setCodec(_codec);
// //    getDuration();
// //  }
// //
// //  @override
// //  void initState() {
// //    super.initState();
// //
// //    //WidgetsBinding.instance.addPostFrameCallback((_) async {
// //    _initializeExample(false);
// //    // });
// //  }
// //
// //  void cancelPlayerSubscriptions() {
// //    if (_playerSubscription != null) {
// //      _playerSubscription.cancel();
// //      _playerSubscription = null;
// //    }
// //  }
// //
// //  @override
// //  void dispose() {
// //    super.dispose();
// //    cancelPlayerSubscriptions();
// //
// //    releaseFlauto();
// //  }
// //
// //  Future<void> releaseFlauto() async {
// //    try {
// //      await playerModule.closeAudioSession();
// //    } catch (e) {
// //      //print('Released unsuccessful');
// //      //print(e);
// //    }
// //  }
// //
// //  Future<void> getDuration() async {
// //    if (await fileExists(widget.filePath)) {
// //      print('heres1 ');
// //      Duration d = await flutterSoundHelper.duration(widget.filePath);
// //
// //      setState(() {
// //        _duration = d != null ? d.inMilliseconds / 1000.0 : null;
// //      });
// //    }
// //  }
// //
// //  Future<bool> fileExists(String path) async {
// //    File file = await new File(path);
// //    return file != null;
// //  }
// //
// //  // In this simple example, we just load a file in memory.This is stupid but just for demonstration  of startPlayerFromBuffer()
// //  Future<Uint8List> makeBuffer(String path) async {
// //    try {
// //      if (!await fileExists(path)) return null;
// //      File file = File(path);
// //      file.openRead();
// //      var contents = await file.readAsBytes();
// //      // //print('The file is ${contents.length} bytes long.');
// //      return contents;
// //    } catch (e) {
// //      //print(e);
// //      return null;
// //    }
// //  }
// //
// //  void _addListeners() {
// //    // cancelPlayerSubscriptions();
// //    getDuration();
// //    _playerSubscription = playerModule.onProgress.listen((e) {
// //      if (e != null) {
// //        maxDuration = e.duration.inMilliseconds.toDouble();
// //        if (maxDuration <= 0) maxDuration = 0.0;
// //
// //        sliderCurrentPosition =
// //            min(e.position.inMilliseconds.toDouble(), maxDuration);
// //        if (sliderCurrentPosition < 0.0) {
// //          sliderCurrentPosition = 0.0;
// //        }
// //
// //        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
// //            e.position.inMilliseconds,
// //            isUtc: true);
// //        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
// //        this.setState(() {
// //          this._playerTxt = txt.substring(0, 8);
// //        });
// //      }
// //    });
// //  }
// //
// //  Future<Uint8List> _readFileByte(String filePath) async {
// //    Uri myUri = Uri.parse(filePath);
// //    File audioFile = new File.fromUri(myUri);
// //    Uint8List bytes;
// //    await audioFile.readAsBytes().then((value) {
// //      bytes = Uint8List.fromList(value);
// //      //print('reading of bytes is completed');
// //    });
// //    return bytes;
// //  }
// //
// //  Future<void> feedHim(String path) async {
// //    Uint8List data = await _readFileByte(path);
// //    return playerModule.feedFromStream(data);
// //  }
// //
// //  Future<String> downloadFile(String url, String fileName, String dir) async {
// //    HttpClient httpClient = new HttpClient();
// //    File file;
// //    String filePath = '';
// //    String myUrl = '';
// //
// //    try {
// //      myUrl = url;
// //      var request = await httpClient.getUrl(Uri.parse(myUrl));
// //      var response = await request.close();
// //      if (response.statusCode == 200) {
// //        var bytes = await consolidateHttpClientResponseBytes(response);
// //        filePath = '$dir/$fileName';
// //        file = File(filePath);
// //        await file.writeAsBytes(bytes);
// //      } else
// //        filePath = 'Error code: ' + response.statusCode.toString();
// //    } catch (ex) {
// //      filePath = 'Can not fetch url';
// //    }
// //
// //    return filePath;
// //  }
// //
// //  Future<void> startPlayer() async {
// //    /* int index = widget.filePath.lastIndexOf('/');
// //    Directory tempDir = await getApplicationDocumentsDirectory();
// //    String path =
// //        '${tempDir.absolute.path}/chckpt_dwnloded${widget.filePath.substring(index)}';
// //
// //    String ppp = await downloadFile(
// //        widget.filePath, widget.filePath.substring(index), tempDir.path);
// //    print('doloded ${await fileExists(path)}');*/
// //    // getDuration();
// //    try {
// //      getDuration();
// //      Uint8List dataBuffer;
// //      String audioFilePath;
// //      Codec codec = _codec;
// //      if (_media == Media.remoteExampleFile) {
// //        if (await fileExists(widget.filePath)) audioFilePath = widget.filePath;
// //        // We have to play an example audio file loaded via a URL
// //        audioFilePath = widget.filePath;
// //      }
// //
// //      // Check whether the user wants to use the audio player features
// //      if (_isAudioPlayer) {
// //        String albumArtUrl;
// //        String albumArtAsset;
// //        String albumArtFile;
// //
// //        albumArtFile =
// //            await playerModule.getResourcePath() + "/images/logo_only.png";
// //        //  //print(albumArtFile);
// //
// //        final track = Track(
// //          trackPath: audioFilePath,
// //          codec: _codec,
// //          dataBuffer: dataBuffer,
// ////          trackTitle: "This is a record",
// ////          trackAuthor: "from flutter_sound",
// //          albumArtUrl: albumArtUrl,
// //          albumArtAsset: albumArtAsset,
// //          albumArtFile: albumArtFile,
// //        );
// //        await playerModule.startPlayerFromTrack(track,
// //            defaultPauseResume: false,
// //            removeUIWhenStopped: true, whenFinished: () {
// //          //print('I hope you enjoyed listening to this song');
// //          stopPlayer();
// //          setState(() {});
// //        }, onSkipBackward: () {
// //          //print('Skip backward');
// //          stopPlayer();
// //          startPlayer();
// //        }, onSkipForward: () {
// //          //print('Skip forward');
// //          stopPlayer();
// //          startPlayer();
// //        }, onPaused: (bool b) {
// //          if (b)
// //            playerModule.pausePlayer();
// //          else
// //            playerModule.resumePlayer();
// //        });
// //      } else {
// //        if (audioFilePath != null) {
// //          await playerModule.startPlayer(
// //              fromURI: audioFilePath,
// //              codec: codec,
// //              sampleRate: SAMPLE_RATE,
// //              whenFinished: () {
// //                print('Play1 finished');
// //                stopPlayer();
// //                setState(() {
// //                  //   stopPlayer();
// //                });
// //              });
// //        }
// //      }
// //      _addListeners();
// //      setState(() {});
// //      //print('<--- startPlayer');
// //    } catch (err) {
// //      //print('error: $err');
// //    }
// //  }
// //
// //  Future<void> stopPlayer() async {
// //    try {
// //      await playerModule.stopPlayer();
// //      //print('stopPlayer');
// //      if (_playerSubscription != null) {
// //        _playerSubscription.cancel();
// //        _playerSubscription = null;
// //      }
// //      sliderCurrentPosition = 0.0;
// //    } catch (err) {
// //      //print('error: $err');
// //    }
// //    this.setState(() {});
// //  }
// //
// //  void pauseResumePlayer() async {
// //    if (playerModule.isPlaying) {
// //      await playerModule.pausePlayer();
// //    } else {
// //      await playerModule.resumePlayer();
// //    }
// //    setState(() {});
// //  }
// //
// //  void seekToPlayer(int milliSecs) async {
// //    //print('-->seekToPlayer');
// //    if (playerModule.isPlaying)
// //      await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
// //    //print('<--seekToPlayer');
// //  }
// //
// //  void Function() onPauseResumePlayerPressed() {
// //    if (playerModule == null) return null;
// //    if (playerModule.isPaused || playerModule.isPlaying) {
// //      return pauseResumePlayer;
// //    }
// //    return null;
// //  }
// //
// //  void Function() onStopPlayerPressed() {
// //    if (playerModule == null) return null;
// //    return (playerModule.isPlaying || playerModule.isPaused)
// //        ? stopPlayer
// //        : null;
// //  }
// //
// //  void Function() onStartPlayerPressed() {
// //    if (playerModule == null) return null;
// //    if (_media == Media.file ||
// //        _media == Media.stream ||
// //        _media == Media.buffer) // A file must be already recorded to play it
// //    {
// //      if (_path[_codec.index] == null) return null;
// //    }
// //    if (_media == Media.remoteExampleFile &&
// //        _codec != Codec.mp3) // in this example we use just a remote mp3 file
// //      return startPlayer;
// //
// //    if (_media == Media.stream && _codec != Codec.pcm16) return null;
// //
// //    if (_media == Media.stream && _isAudioPlayer) return null;
// //
// //    // Disable the button if the selected codec is not supported
// //    if (!(_decoderSupported || _codec == Codec.pcm16)) return null;
// //
// //    return (playerModule.isStopped) ? startPlayer : null;
// //  }
// //
// //  void setCodec(Codec codec) async {
// //    _decoderSupported = await playerModule.isDecoderSupported(codec);
// //
// //    setState(() {
// //      _codec = codec;
// //    });
// //  }
// //
// //  @override
// //  Widget build(BuildContext context) {
// //    //getDuration();
// //
// //    Widget playerSection = Column(
// //      crossAxisAlignment: CrossAxisAlignment.center,
// //      mainAxisAlignment: MainAxisAlignment.center,
// //      mainAxisSize: MainAxisSize.min,
// //      children: <Widget>[
// //        Row(
// //          children: <Widget>[
// //            Container(
// //              child: Center(
// //                child: FloatingActionButton(
// //                  clipBehavior: Clip.hardEdge,
// //                  backgroundColor: Color(0xff293e52),
// //                  elevation: 1,
// //                  child: playerModule.isPlaying
// //                      ? IconButton(
// //                          icon: Icon(
// //                            Icons.pause,
// //                            color: Colors.white,
// //                          ),
// //                          onPressed: () => playerModule.pausePlayer(),
// //                        )
// //                      : IconButton(
// //                          icon: Icon(
// //                            Icons.play_arrow,
// //                            color: Colors.white,
// //                          ),
// //                          onPressed: playerModule.isPaused
// //                              ? playerModule.resumePlayer
// //                              : startPlayer,
// //                        ),
// //                ),
// //              ),
// //            ),
// //            Container(
// //                child: Slider(
// //                    value: min(sliderCurrentPosition, maxDuration),
// //                    min: 0.0,
// //                    max: maxDuration,
// //                    activeColor: Color(0xff293e52),
// //                    inactiveColor: Color(0xff293e52).withOpacity(.2),
// //                    onChanged: (double value) async {
// //                      await seekToPlayer(value.toInt());
// //                    },
// //                    divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt())),
// //          ],
// //          mainAxisAlignment: MainAxisAlignment.center,
// //          crossAxisAlignment: CrossAxisAlignment.center,
// //        ),
// //        playerModule.isPlaying
// //            ? Row(
// //                children: [
// //                  Container(
// //                    child: Text(
// //                      this._playerTxt,
// //                      style: TextStyle(
// //                        fontSize: 14.0,
// //                        color: Colors.black,
// //                      ),
// //                    ),
// //                  ),
// //                  Container(
// //                    //  height: 30.0,
// //                    child: Text(_duration != null
// //                        ? "/${_duration.round()} ${'sec.'.tr()}"
// //                        : ''),
// //                  ),
// //                ],
// //              )
// //            : Container(
// //                //  height: 30.0,
// //                child: Text(_duration != null
// //                    ? "${_duration.round()} ${'sec.'.tr()}"
// //                    : ''),
// //              ),
// //      ],
// //    );
// //
// //    return Center(
// //      child: Container(
// //        decoration: BoxDecoration(
// //            color: Colors.grey[200], borderRadius: BorderRadius.circular(7)),
// //        child: playerSection,
// //      ),
// //    );
// //  }
// //}
