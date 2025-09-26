# Flutter Music Player

A mobile music player application built with Flutter, designed to provide a seamless and feature-rich audio experience. The application supports local music playback, online radio streaming, and full playlist management synchronized with a Firebase backend.

## Key Features

* **Song and Playlist Management**
    * **Local File Upload**: Users can upload audio files (MP3, FLAC, WAV, etc.) directly from their device storage.
    * **Metadata Extraction**: The application automatically reads metadata tags from audio files to populate song title, artist, and album artwork.
    * **Firebase Synchronization**: All songs and playlists are stored and managed using Cloud Firestore and Firebase Storage, ensuring data persistence.
    * **Playlist Creation**: Users can create, view, edit, and delete custom playlists.

* **Audio Playback System**
    * **Background Playback**: Audio continues to play seamlessly when the app is in the background, managed by `just_audio_background`.
    * **Queue Management**: A dedicated interface allows users to view and manage the current song queue.
    * **Standard Controls**: Provides a full suite of playback controls, including play, pause, seek, skip, repeat, and shuffle.

* **User Interface**
    * **Dual Theming**: Includes distinct, user-selectable light and dark themes.
    * **Search Functionality**: Users can search for specific songs, playlists, or radio stations within their respective libraries.
    * **Navigation**: A clean navigation drawer provides easy access to all primary features including the song library, playlists, and radio.

## Technology Stack

* **Framework**: Flutter
* **Language**: Dart
* **Backend**: Firebase
    * **Database**: Cloud Firestore
    * **Storage**: Firebase Storage
* **Audio**:
    * `just_audio` & `just_audio_background`: Core audio playback and background service.
    * `audio_video_progress_bar`: For displaying playback progress.
    * `audiotags`: For reading metadata from audio files.
* **State Management**:
    * `provider`
    * `StreamBuilder` with `rxdart` for managing reactive data streams from Firebase and the audio player.
* **File and Permission Handling**:
    * `file_picker` & `image_picker`: For selecting files from the device.
    * `permission_handler`: For managing necessary storage permissions.
* **UI and Utilities**:
    * `theme_provider`: For managing application-wide themes.
    * `cached_network_image`: For efficient loading and caching of network images.

## Project Architecture

The codebase is organized to promote separation of concerns and maintainability:

* **/lib/pages**: Contains all primary screens (widgets) for different features, such as the home page, player interface, playlist viewer, and file upload screens.
* **/lib/components**: Includes reusable data models (`Song`, `Playlist`) and common UI widgets used across multiple pages.
* **/lib/themes**: Defines the `ThemeData` for the application's light and dark modes.
* **main.dart**: The application's entry point, which handles initialization for Firebase, background audio services, and theme management.