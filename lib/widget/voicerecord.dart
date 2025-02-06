import 'dart:convert';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:neonpen/neonpen.dart';
import 'package:picturediary/widget/textedit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:overlay_loading_progress/overlay_loading_progress.dart';

class VoiceRecorder extends StatefulWidget {
  final DateTime selectedDate;

  const VoiceRecorder({super.key, required this.selectedDate});
  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  bool _isProcessing = false;
  IOS9SiriWaveformController? _siriWaveController;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
    _siriWaveController = IOS9SiriWaveformController(
      amplitude: 0.3,
      speed: 0.1,
    );
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  Future<void> _initializeRecorder() async {
    final status = await Permission.microphone.request();
    await _requestPermission(Permission.storage);
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder!.openRecorder();
    _recorder!.setSubscriptionDuration(const Duration(milliseconds: 50));
  }

  Future<void> _startRecording() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _filePath = '$appDocPath/my_recording.wav';

    await _recorder!.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
    );
    setState(() {
      _isRecording = true;
    });

    _recorder!.onProgress!.listen((event) {
      final decibels = event.decibels ?? 0.0;
      setState(() {
        _siriWaveController!.amplitude = (decibels / 20).clamp(0.1, 1.0);
      });
    });
  }

  //리코딩 작업 끝날 때 처리 여기서 STT 넘어감

  Future<void> _stopRecording() async {
    final path = await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _siriWaveController!.amplitude = 0.0;
    });
    print('Recording saved to: $path');

    if (_filePath != null) {
      setState(() {
        _isProcessing = true;
      });

      Future.delayed(Duration(milliseconds: 1000), () async {
        final text = await _convertSpeechToText(_filePath!);

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TextEditPage(text: text, selectedDate: widget.selectedDate),
          ),
        );
      });
    } else {
      print('파일 경로가 설정되지 않았습니다.');
    }
  }

  //STT 적용
  Future<String> _convertSpeechToText(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final url = Uri.parse('http://..:3000/v2/models/whisper/infer');

    String encodedData = base64Encode(bytes);

    print(encodedData);
    var req = {
      "inputs": [
        {
          "name": "audio_url",
          "datatype": "BYTES",
          "shape": [1],
          "data": [encodedData]
        },
      ]
    };

    var jsonData = jsonEncode(req);
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );
    if (response.statusCode == 307) {
      var newUrl = response.headers['location'];
      if (newUrl != null) {
        response = await http.post(
          Uri.parse(newUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonData,
        );
      }
    }
    var chatAnswer = '';
    if (response.statusCode == 200) {
      print('answer: ${response.statusCode}');

      var data = jsonDecode(utf8.decode(response.bodyBytes));

      chatAnswer = (data['outputs'][0]['data'][0]);
    }

    print(chatAnswer);
    return chatAnswer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(''),
        backgroundColor:
            !_isProcessing ? Colors.white : Colors.grey.withOpacity(0.5),
      ),
      body: Center(
        child: _isProcessing
            ? Stack(
                children: [
                  Container(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitFadingCircle(
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? Color.fromARGB(255, 240, 255, 103)
                                    : Color.fromARGB(221, 106, 255, 101),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20), // 간격 조절
                        Text(
                          '일기가 생성중이에요!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Neonpen(
                    text: Text(
                      _isRecording ? '지금 말을 녹음중이에요' : '오늘을 기록해보세요',
                      style: TextStyle(
                        fontSize: 35,
                        fontFamily: 'daehan',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: _isRecording ? Colors.red : Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    opacity: 0.2,
                    emphasisWidth: 10,
                    emphasisOpacity: 0.4,
                    emphasisAngleDegree: 2,
                    enableLineZiggle: true,
                    lineZiggleLevel: 2,
                    isDoubleLayer: true,
                  ),
                  SizedBox(height: 20),
                  _isRecording
                      ? SiriWaveform.ios9(
                          controller: _siriWaveController!,
                          options: IOS9SiriWaveformOptions(
                            height: 150,
                            width: 270,
                          ),
                        )
                      : Container(),
                  !_isRecording
                      ? SizedBox(height: 100)
                      : SizedBox(
                          height: 20,
                        ),
                  AvatarGlow(
                    glowColor: !_isRecording ? Colors.blue : Colors.white,
                    duration: Duration(milliseconds: 3000),
                    repeat: true,
                    child: Material(
                      elevation: 7.0,
                      shape: CircleBorder(),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        child: IconButton(
                          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                          onPressed:
                              _isRecording ? _stopRecording : _startRecording,
                          color: _isRecording ? Colors.red : Colors.blue,
                          iconSize: 70,
                        ),
                        radius: 50.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  )
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }
}
