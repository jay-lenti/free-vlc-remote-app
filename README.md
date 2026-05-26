# VLC Remote

A simple, lightweight Flutter application to remotely control a VLC media player instance running on your local network.

## Features

- **Playback Control:** Play, pause, stop, next, and previous track.
- **Volume Management:** Adjustable volume slider (0-200%) with a quick mute toggle.
- **Seeking:** Jump to specific parts of the track using the seek bar.
- **Playlist:** View the current playlist and switch tracks instantly.
- **Live Status:** Real-time updates for track title, artist, and playback progress.
- **Persistence:** Remembers your last connection settings (IP, Port, Password).

## Screenshots

*(Add screenshots here)*

## Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- VLC Media Player installed on a host computer.

### VLC Setup

1. Open VLC on your computer.
2. Go to **Preferences** (Cmd+, on Mac, Ctrl+P on Windows).
3. Select **All** under "Show settings".
4. Navigate to **Interface > Main interfaces**.
5. Check the **Web** box.
6. Navigate to **Interface > Main interfaces > Lua**.
7. Set a **Lua HTTP Password**.
8. Restart VLC.

### Build and Run

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/vlc-remote.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## CI/CD

This project uses GitHub Actions to automatically build:
- **Android:** Release APK
- **iOS:** Unsigned app bundle

## License

MIT License - see [LICENSE](LICENSE) for details.
