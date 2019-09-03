import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioData with ChangeNotifier {
  bool dataIsReady = false;
  FlutterAudioQuery query = new FlutterAudioQuery();
  List<SongInfo> songs = [];
  List<AlbumInfo> albums = [];
  List<ArtistInfo> artists = [];
  List<PlaylistInfo> playlists = [];
  List<String> recents;

  AudioData() {
    getAllData();
  }

  void getAllData() async {
    songs = await query.getSongs();
    albums = await query.getAlbums();
    artists = await query.getArtists();
    playlists = await query.getPlaylists();
    dataIsReady = true;
    notifyListeners();
  }

  void addPlaylist(PlaylistInfo playlist) {
    playlists.add(playlist);
    notifyListeners();
  }

  void removePlaylist(PlaylistInfo playlist) {
    playlists.remove(playlist);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

}

class AudioPlayerInfo with ChangeNotifier {
  List<SongInfo> currentPlayingList;
  SongInfo currentPlayingSong;
  String currentPage;
  int currentIndex;
  double durationPlayedPercent;
  bool shouldDisplayProgress;
  PageController musicScreenPageController;

  AudioPlayer audioPlayer;

  AudioPlayerInfo(
      {this.currentPlayingList,
      this.currentPlayingSong,
      this.currentIndex = 0,
      this.currentPage = "Tracks"}) {
    audioPlayer = new AudioPlayer();
    audioPlayer.state = AudioPlayerState.STOPPED;
    durationPlayedPercent = 0;
    shouldDisplayProgress = false;
    currentIndex = 0;
    musicScreenPageController = PageController(initialPage: 0);
    audioPlayer.onPlayerCompletion.listen((_) {
      skipNext();
      musicScreenPageController.animateToPage(
                  (musicScreenPageController.page.round() + 1) % currentPlayingList.length,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutQuint);
    });
    audioPlayer.onAudioPositionChanged.listen((d){
      durationPlayedPercent = d.inMilliseconds / int.parse(currentPlayingSong.duration);
      if(shouldDisplayProgress) notifyListeners();
    });
  }

  set currentSong(int index) {
    if (currentPlayingList.isNotEmpty) {
      currentIndex = index;
      currentPlayingSong = currentPlayingList[index];
      durationPlayedPercent = 0.0;
      notifyListeners();
    }
    if(audioPlayer.state == AudioPlayerState.STOPPED || audioPlayer.state == AudioPlayerState.PAUSED)
      return;
    else 
      play();
  }

  void setCurrentSongList(List<SongInfo> songs, String page) {
    if (currentPage == page)
      return;
    else {
      currentPlayingList = songs;
      currentSong = 0;
      currentPage = page;
      notifyListeners();
    }
  }

  void skipNext() {
    if (currentPlayingList.isNotEmpty) {
      currentIndex = (currentIndex + 1) % currentPlayingList.length;
      currentSong = currentIndex;
    }
    play();
    notifyListeners();
  }

  void skipPrevious() {
    if (currentPlayingList.isNotEmpty) {
      currentIndex =
          currentIndex == 0 ? currentPlayingList.length - 1 : currentIndex - 1;
      currentSong = currentIndex;
    }
    play();
    notifyListeners();
  }

  void play() async {
    audioPlayer.state = AudioPlayerState.PLAYING;
    await audioPlayer.play(currentPlayingSong.filePath, isLocal: true);
    notifyListeners();
  }

  void pause() async {
    audioPlayer.state = AudioPlayerState.PAUSED;
    await audioPlayer.pause();
    notifyListeners();
  }

  void resume() async {
    play();
  }

  void seekForward(){
    if(shouldDisplayProgress){
    double forwardSkip = double.parse(currentPlayingSong.duration) * (durationPlayedPercent + 0.0013);
    Duration duration = new Duration(milliseconds: forwardSkip.toInt());
    durationPlayedPercent += 0.0013;
    audioPlayer.seek(duration);
    notifyListeners();
    }
  }

  void seekBackward(){
    if(shouldDisplayProgress){
    double backwardSkip = double.parse(currentPlayingSong.duration) * (durationPlayedPercent - 0.0013);
    Duration duration = new Duration(milliseconds: backwardSkip.toInt());
    durationPlayedPercent -= 0.0013;
    audioPlayer.seek(duration);
    notifyListeners();
    }
  }
}
