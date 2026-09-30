# FileShare

A file sharing app I built with Flutter. You pick some files, it finds another phone nearby, and you send them. It works kind of like LocalSend or AirDrop, but Android only for now. No internet needed.

I built it because I wanted something simple for sending stuff between phones, and because it is actually a good project for my portfolio.

## Download

You can get the APK from the [Releases page](https://github.com/Tosin2510/fileShare_app/releases/latest) and install it on your phone. You should also allow installs from unknown sources when it pops up on your android device. Note, both phones need the app.

Nothing else to set up. Just install it, accept the permissions and you're good.

## How it works

Devices find each other with mDNS, using the [bonsoir](https://pub.dev/packages/bonsoir) package. Once a phone pops up, an handshake happens and file transfer happens through an http server i set up with shelf [shelf](https://pub.dev/packages/shelf).

Because of this, both phones should be on the same local network. Either

- both phones are on the same third-party Wi-Fi, or
- one phone has its hotspot on and the other connects to it

You have to manually turn the hotspot on yourself. Turning it on automatically from Flutter is really hard (close to impossible), so I left it manual. The phones just need to be able to reach each other. If you don't see a nearby device, check that first or refresh again.

## What it does

- Send photos, videos, music, documents, or even installed apps (as APKs) to any device it finds
- A list of devices available on the local network
- Progress tracking for the transfer progress as well as a button that leads back to the transfer screen if you leave the screen.
- History of past transfers grouped by date.
- Settings to change your device name, turn animations off as well as clear cached files

Received photos and videos go straight to the device Gallery and APKs and audio go to their respective folder. You can also find the files in the download folder.

## Built with

Flutter and Dart

- bonsoir for device discovery
- shelf and shelf_router for the setting up of the local server
- dio for uploading from the sender side
- sqflite for the history database
- gal and media_store_plus for saving files to the right folders
- wechat_assets_picker and file_picker for choosing files
- installed_apps for picking apps to share

## Running it from source

You need the Flutter SDK. Two real Android phones are best for testing. An emulator will run the app, but you'd still need a second device or emulator on the same network to send anything.

1. `git clone https://github.com/Tosin2510/fileShare_app.git`
2. `cd fileShare_app`
3. `flutter pub get`
4. Connect a device and run `flutter run`

For a release APK: `flutter build apk --release`

## Things that don't work well yet

- Both phones have to be on the same network. There's no way to connect two phones that are not on the same local network.
- Android only for now
- Sending a lot of files at once can take a while to start.

The project is basically still a work in progress.

## Screenshots from the app

<img width="271" height="616" alt="image" src="https://github.com/user-attachments/assets/0b6bcb7f-4902-4ac6-b2e2-a09e06d1b5a3" />
<img width="279" height="609" alt="image" src="https://github.com/user-attachments/assets/e12df0de-f79e-46b8-bf7d-770c5ba4ae06" />
<img width="269" height="612" alt="image" src="https://github.com/user-attachments/assets/51d16acc-1fed-4a0d-86cf-30cf5eabe0c9" />
<img width="267" height="602" alt="image" src="https://github.com/user-attachments/assets/7ef7d944-0e96-4165-8880-8df9a02b1714" />


