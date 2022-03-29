import 'package:audio_session/audio_session.dart';
import 'package:blue_player/components/seek_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:blue_player/models/audio_metadata.dart';
import 'package:blue_player/components/control_buttons.dart';

class AudioScreen extends StatefulWidget {
  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  AudioPlayer _player;

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(
      Uri.parse("http://192.168.42.41:8080/songs/1/hls/m1.m3u8"),
      tag: AudioMetadata(
          album: "Uchastok",
          title: "Berezy",
          artwork:
              "https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Betula_pendula_001.jpg/1200px-Betula_pendula_001.jpg"),
    ),
  ]);

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("An error occured $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamBuilder<SequenceState>(
                stream: _player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state?.sequence?.isEmpty ?? true) return SizedBox();
                  final metadata = state.currentSource.tag as AudioMetadata;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Image.network(metadata.artwork),
                          ),
                        ),
                      ),
                      Text(
                        metadata.album ?? '',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text(metadata.title ?? ''),
                    ],
                  );
                },
              ),
            ),
            ControlButtons(_player),
            StreamBuilder<Duration>(
              stream: _player.durationStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, snapshot) {
                    var position = snapshot.data ?? Duration.zero;
                    if (position > duration) {
                      position = duration;
                    }
                    return SeekBar(
                      duration: duration,
                      position: position,
                      onChangeEnd: (newPosition) {
                        _player.seek(newPosition);
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(
              height: 8.0,
            ),
            Row(
              children: [
                StreamBuilder<LoopMode>(
                    stream: _player.loopModeStream,
                    builder: (context, snapshot) {
                      final loopMode = snapshot.data ?? LoopMode.off;
                      const icon = [
                        Icon(
                          Icons.repeat,
                          color: Colors.grey,
                        ),
                        Icon(
                          Icons.repeat,
                          color: Colors.orange,
                        ),
                        Icon(
                          Icons.repeat_one,
                          color: Colors.orange,
                        ),
                      ];
                      const cycleMode = [
                        LoopMode.off,
                        LoopMode.one,
                        LoopMode.all,
                      ];
                      final index = cycleMode.indexOf(loopMode);
                      return IconButton(
                          icon: icon[index],
                          onPressed: () {
                            _player.setLoopMode(cycleMode[
                                (cycleMode.indexOf(loopMode) + 1) %
                                    cycleMode.length]);
                          });
                    }),
                Expanded(
                  child: Text(
                    "Playlist",
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                ),
                StreamBuilder<bool>(
                  stream: _player.shuffleModeEnabledStream,
                  builder: (context, snapshot) {
                    final shuffleModeEnabled = snapshot.data ?? false;
                    return IconButton(
                        icon: shuffleModeEnabled
                            ? Icon(Icons.shuffle, color: Colors.orange)
                            : Icon(Icons.shuffle, color: Colors.grey),
                        onPressed: () {
                          _player.setShuffleModeEnabled(!shuffleModeEnabled);
                        });
                  },
                ),
              ],
            ),
            Container(
              height: 240.0,
              child: StreamBuilder<SequenceState>(
                stream: _player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final sequence = state?.sequence ?? [];
                  return ListView.builder(
                    itemCount: sequence.length,
                    itemBuilder: (context, index) => Material(
                      color: index == state.currentIndex
                          ? Colors.grey.shade300
                          : null,
                      child: ListTile(
                          title: Text(sequence[index].tag.title),
                          onTap: () {
                            _player.seek(Duration.zero, index: index);
                          }),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
