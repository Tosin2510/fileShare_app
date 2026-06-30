import 'package:flutter/material.dart';

enum FilePickerOption {
  media(Icons.image),
  file(Icons.description_outlined),
  audio(Icons.music_note_outlined),
  apps(Icons.grid_view_rounded);

  const FilePickerOption(this.icon);
  final IconData icon;

}