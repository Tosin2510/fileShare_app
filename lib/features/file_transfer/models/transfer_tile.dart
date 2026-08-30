import 'package:flutter/material.dart';
// This model is used in the ui for the transfer tile.
class TransferTile {
  final String id;
  final String fileName;
  final IconData icon;
  final String sizeLabel;
  final String? statusLabel;
  final Color? statusColor;
  final Widget trailing;

  const TransferTile({
    required this.id,
    required this.fileName,
    required this.icon,
    required this.sizeLabel,
    this.statusLabel,
    this.statusColor,
    required this.trailing,
  });
}