// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:music_player/domain/playlists/playlist_item.dart';
// import 'package:music_player/services/audio/audio_player_service.dart';
// import 'package:provider/provider.dart';

//   /// A button that plays or pauses the audio.
//   ///
//   /// If the audio is playing, a pause button is shown.
//   /// If the audio has finished playing, a restart button is shown.
//   /// If the audio is paused, or not started yet, a play button is shown.
//   /// If the audio is loading, a progress indicator is shown.
//   Widget _playPauseButton(
//       ProcessingState processingState, AudioPlayer player) {
//     if (processingState == ProcessingState.loading ||
//         processingState == ProcessingState.buffering) {
//       return Container(
//         margin: EdgeInsets.all(8.0),
//         width: 64.0,
//         height: 64.0,
//         child: CircularProgressIndicator(),
//       );
//     } else if (processingState == ProcessingState.ready) {
//       return IconButton(
//         icon: Icon(Icons.play_arrow),
//         iconSize: 64.0,
//         onPressed: player.play,
//       );
//     } else if (processingState != ProcessingState.completed) {
//       return IconButton(
//         icon: Icon(Icons.pause),
//         iconSize: 64.0,
//         onPressed: player.pause,
//       );
//     } else {
//       return IconButton(
//         icon: Icon(Icons.replay),
//         iconSize: 64.0,
//         onPressed: () => player.seek(Duration.zero),
//       );
//     }
//   }

//   /// A shuffle button. Tapping it will either enabled or disable shuffle mode.
//   Widget _shuffleButton(
//       BuildContext context, bool isEnabled, AudioPlayer player) {
//     return IconButton(
//       icon: isEnabled
//           ? Icon(Icons.shuffle, color: Theme.of(context).colorScheme.secondary)
//           : Icon(Icons.shuffle),
//       onPressed: () async {
//         final enable = !isEnabled;
//         await player.setShuffleModeEnabled(enable);
//       },
//     );
//   }

//   /// A previous button. Tapping it will seek to the previous audio in the list.
//   Widget _previousButton(AudioPlayer player) {
//     return IconButton(
//       icon: Icon(Icons.skip_previous),
//       onPressed: player.hasPrevious ? player.seekToPrevious : null,
//     );
//   }

//   /// A next button. Tapping it will seek to the next audio in the list.
//   Widget _nextButton(AudioPlayer player) {
//     return IconButton(
//       icon: Icon(Icons.skip_next),
//       onPressed: player.hasNext ? player.seekToNext : null,
//     );
//   }

//   /// A repeat button. Tapping it will cycle through not repeating, repeating
//   /// the entire list, or repeat the current audio.
//   Widget _repeatButton(BuildContext context, PlaylistLoopMode loopMode,
//       AudioPlayer player) {
//     final icons = [
//       Icon(Icons.repeat),
//       Icon(Icons.repeat, color: Theme.of(context).colorScheme.secondary),
//       Icon(Icons.repeat_one, color: Theme.of(context).colorScheme.secondary),
//     ];
//     const cycleModes = [
//       PlaylistLoopMode.off,
//       PlaylistLoopMode.all,
//       PlaylistLoopMode.one,
//     ];
//     final index = cycleModes.indexOf(loopMode);
//     return IconButton(
//       icon: icons[index],
//       onPressed: () {
//         player.setLoopMode(
//             cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
//       },
//     );
//   }
// }