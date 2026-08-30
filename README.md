# FileShare

This is a local network file-sharing app that is built using Flutter, inspired by apps like LocalSend and Airdrop on ios. FileShare allows you to send files, photos, videos, music, documents, and even installed apps (APKs) between two Android devices without an internet connection.

## Why I built this

Most file-sharing apps either need both people to be online, or they're bloated with ads and unrelated features. I wanted something simple: pick your files, find a nearby device, send. No accounts, no cloud, no internet required, just your local network. Also, i built this because it is an interesting project to work on

## How it works

FileShare uses **mDNS (multicast DNS)** via the flutter bonsoir [bonsoir](https://pub.dev/packages/bonsoir) package to discover other devices that has the app currently running on the same local network. Once a device has been found, an HTTP server which I built with shelf [shelf](https://pub.dev/packages/shelf) handles the actual device handshake and file transfer between the two phones(android for now).

**For a file transfer to work, both devices need to be on the same local network.** In this case, this either :

- Both phones are connected to the same Wi-Fi network (like a home router), **or**
- One phone turns on its mobile hotspot, and the other phone connects to that hotspot manually.

This is a deliberate design choice I made...since there's no server or cloud involved, both devices genuinely need to be reachable on the same network for discovery and transfer to happen.Also, the manual hotspot turning on option is because it is hard if not nearly impossible to implement automatic hotspot switching on in flutter. If you're not seeing a nearby device, the first thing to check is whether both phones are actually on the same network.

## Features

- **Send** — pick media (photos/videos), music, documents, or installed apps, then send them to any discovered nearby device.
- **Receive** — your device broadcasts itself on the network automatically, and shows an accept/decline prompt whenever someone tries to send you files.
- **Transfer progress** — live progress tracking for both sent and received files, with a small floating indicator that stays visible even if you navigate away mid-transfer.
- **History** — a record of past transfers, grouped by date, with the ability to reopen received files directly or clear old entries.
- **Settings** — change your device's display name (what other devices see you as), toggle UI animations, and clear cached/temporary files.

Received images and videos are saved straight to your device's Gallery, and other files (documents, APKs, music) go to your Downloads folder and other folders like the APK folder, the audio folder(if any exists) so everything ends up where you can actually expect to find it, not buried in some app-only folder.

## Platform support

Right now, FileShare is **Android only**. iOS isn't supported yet, a lot of the underlying mechanics like background network access, reading a device's own hotspot info, saving files into shared system folders work very differently on iOS, and would need separate work to support properly.

## Tech stack

- **Flutter / Dart**
- **bonsoir** — mDNS-based device discovery and broadcasting
- **shelf / shelf_router** — local HTTP server for the send/receive handshake and file streaming
- **dio** — handling the sender side of file uploads
- **sqflite** — local database for transfer history
- **gal** / **media_store_plus** — saving received files into the correct system folders (Gallery, Downloads, etc.)
- **wechat_assets_picker** / **file_picker** — picking photos, videos, and files to send
- **installed_apps** — picking and locating installed apps to share as APKs

## Getting started

# Prerequisites
Flutter SDK installed and set up
An Android device or emulator, two physical Android devices are recommended for actually testing transfers but an emulator can run the app, but you'll need a second real device (or a second emulator on the same network) to send/receive between

# Setup

1. Clone the repository:
   git clone https://github.com/Tosin2510/fileShare_app.git
   cd fileShare_app
2. Install dependencies:
   flutter pub get
3. Connect a device or start an emulator, then run:
   flutter run
4. Building a release APK
   flutter build apk --release

# Testing It
Test it using preferaly two physical android devices, accept the permissions and carry on with transfer.


## Known limitations

- Both devices must be on the same local network, there's currently no way to auto-connect two phones that are not already sharing a network.
- Android only, for now.
- Large batch transfers (i.e lots of files at once) can take a moment to prepare on the sending side, since each file needs to be read and sized before sending begins.

## Status

This is an actively developed personal project, I will continue to refine the transfer flow, UI polish, and reliability across different devices and versions.

