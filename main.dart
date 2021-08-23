import 'package:flutter/material.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: FacadeExample(),
        ),
      ),
    );
  }
}

class FacadeExample extends StatefulWidget {
  @override
  _FacadeExampleState createState() => _FacadeExampleState();
}

class _FacadeExampleState extends State<FacadeExample> {
  final SmartHomeFacade _smartHomeFacade = SmartHomeFacade();
  final SmartHomeState _smartHomeState = SmartHomeState();
  
  bool _homeCinemaModeOn = false;
  bool _gamingModeOn = false;
  bool _streamingModeOn = false;
  
  bool get _isAnyModeOn =>
    _homeCinemaModeOn || _gamingModeOn || _streamingModeOn;
  
  void _changeHomeCinemaMode(bool activated) {
    if (activated) {
      _smartHomeFacade.startMovie(_smartHomeState, "Movie title");
    } else {
      _smartHomeFacade.stopMovie(_smartHomeState);
    }
    
    setState(() {
      _homeCinemaModeOn = activated;
    });
  }
  
  void _changeGamingMode(bool activated) {
    if (activated) {
      _smartHomeFacade.startGaming(_smartHomeState);
    } else {
      _smartHomeFacade.stopGaming(_smartHomeState);
    }
    
    setState(() {
      _gamingModeOn = activated;
    });
  }
  
  void _changeStreamingMode(bool activated) {
    if (activated) {
      _smartHomeFacade.startStreaming(_smartHomeState);
    } else {
      _smartHomeFacade.stopStreaming(_smartHomeState);
    }
    
    setState(() {
      _streamingModeOn = activated;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CheckboxListTile(
                    activeColor: darkBlue,
                    title: Text('Home Cinema mode'),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _homeCinemaModeOn,
                    onChanged: !_isAnyModeOn || _homeCinemaModeOn ? _changeHomeCinemaMode : null,
                  ),
                  CheckboxListTile(
                    activeColor: darkBlue,
                    title: Text('Gaming mode'),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _gamingModeOn,
                    onChanged: !_isAnyModeOn || _gamingModeOn ? _changeGamingMode : null,
                  ),
                  CheckboxListTile(
                    activeColor: darkBlue,
                    title: Text('Streaming mode'),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _streamingModeOn,
                    onChanged: !_isAnyModeOn || _streamingModeOn ? _changeStreamingMode : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0 * 2),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: _smartHomeState.tvOn
                        ? Icon(Icons.monitor) : Icon(Icons.monitor_outlined)
                    ),
                    IconButton(
                      icon: _smartHomeState.netflixConnected
                        ? Icon(Icons.local_movies) : Icon(Icons.local_movies_outlined)
                    ),
                    IconButton(
                      icon: _smartHomeState.audioSystemOn
                        ? Icon(Icons.speaker) : Icon(Icons.speaker_outlined)
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: _smartHomeState.gamingConsoleOn
                        ? Icon(Icons.videogame_asset) : Icon(Icons.videogame_asset_outlined)
                    ),
                    IconButton(
                      icon: _smartHomeState.gamingConsoleOn
                        ? Icon(Icons.videocam) : Icon(Icons.videocam_outlined)
                    ),
                    IconButton(
                      icon: _smartHomeState.lightsOn
                        ? Icon(Icons.flash_on) : Icon(Icons.flash_off)
                    ),
                  ]
                )
              ]
            )
          ]
        )
      )
    );
  }
}

class GamingFacade {
  final PlaystationApi _playstationApi = PlaystationApi();
  final CameraApi _cameraApi = CameraApi();
  
  void startGaming(SmartHomeState smartHomeState) {
    smartHomeState.gamingConsoleOn = _playstationApi.turnOn();
  }
  
  void stopGaming(SmartHomeState smartHomeState) {
    smartHomeState.gamingConsoleOn = _playstationApi.turnOff();
  }
  
  void startStreaming(SmartHomeState smartHomeState) {
    smartHomeState.streamingCameraOn = _cameraApi.turnCameraOn();
    startGaming(smartHomeState);
  }
  
  void stopStreaming(SmartHomeState smartHomeState) {
    smartHomeState.streamingCameraOn = _cameraApi.turnCameraOff();
    stopGaming(smartHomeState);
  }
}

class SmartHomeFacade {
  final GamingFacade _gamingFacade = GamingFacade();
  final TvApi _tvApi = TvApi();
  final AudioApi _audioApi = AudioApi();
  final NetflixApi _netflixApi = NetflixApi();
  final SmartHomeApi _smartHomeApi = SmartHomeApi();
  
  void startMovie(SmartHomeState smartHomeState, String movieTitle) {
    smartHomeState.lightsOn = _smartHomeApi.turnLightsOff();
    smartHomeState.tvOn = _tvApi.turnOn();
    smartHomeState.audioSystemOn = _audioApi.turnSpeakersOn();
    smartHomeState.netflixConnected = _netflixApi.connect();
    _netflixApi.play(movieTitle);
  }
  
  void stopMovie(SmartHomeState smartHomeState) {
    smartHomeState.netflixConnected = _netflixApi.disconnect();
    smartHomeState.tvOn = _tvApi.turnOff();
    smartHomeState.audioSystemOn = _audioApi.turnSpeakersOff();
    smartHomeState.lightsOn = _smartHomeApi.turnLightsOn();
  }
  
  void startGaming(SmartHomeState smartHomeState) {
    smartHomeState.lightsOn = _smartHomeApi.turnLightsOff();
    smartHomeState.tvOn = _tvApi.turnOn();
    _gamingFacade.startGaming(smartHomeState);
  }
  
  void stopGaming(SmartHomeState smartHomeState) {
    _gamingFacade.stopGaming(smartHomeState);
    smartHomeState.tvOn = _tvApi.turnOff();
    smartHomeState.lightsOn = _smartHomeApi.turnLightsOn();
  }
  
  void startStreaming(SmartHomeState smartHomeState) {
    smartHomeState.lightsOn = _smartHomeApi.turnLightsOn();
    smartHomeState.tvOn = _tvApi.turnOn();
    _gamingFacade.startStreaming(smartHomeState);
  }
  
  void stopStreaming(SmartHomeState smartHomeState) {
    _gamingFacade.stopStreaming(smartHomeState);
    smartHomeState.tvOn = _tvApi.turnOff();
    smartHomeState.lightsOn = _smartHomeApi.turnLightsOn();
  }
}

class AudioApi {
  bool turnSpeakersOn() {
    return true;
  }
  
  bool turnSpeakersOff() {
    return false;
  }
}

class CameraApi {
  bool turnCameraOn() {
    return true;
  }
  
  bool turnCameraOff() {
    return false;
  }
}

class NetflixApi {
  bool connect() {
    return true;
  }
  
  bool disconnect() {
    return false;
  }
  
  void play(String title) {
    print("'$title' has started playing on Netflix.");
  }
}

class PlaystationApi {
  bool turnOn() {
    return true;
  }
  
  bool turnOff() {
    return false;
  }
}

class SmartHomeApi {
  bool turnLightsOn() {
    return true;
  }
  
  bool turnLightsOff() {
    return false;
  }
}

class TvApi {
  bool turnOn() {
    return true;
  }
  
  bool turnOff() {
    return false;
  }
}

class SmartHomeState {
  bool tvOn = false;
  bool audioSystemOn = false;
  bool netflixConnected = false;
  bool gamingConsoleOn = false;
  bool streamingCameraOn = false;
  bool lightsOn = true;
}
