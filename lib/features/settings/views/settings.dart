import 'package:file_share_app/features/app_management/services/cache_service.dart';
import 'package:file_share_app/features/device_discovery/services/device_name_service.dart';
import 'package:file_share_app/features/file_transfer/services/transfer_history.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _deviceName = '';
  String _appVersion = '';
  String _cacheSize = '';
  bool _animationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceName();
    _loadInfoAbtApp();
    _loadCacheSize();
    _loadAnimationPreference();
  }

  Future<void> _loadDeviceName() async {
    final name = await DeviceNameService.getDeviceName();
    if (mounted) {
      setState(() {
        _deviceName = name;
      });
    }
  }

  Future<void> _clearTransferHistory() async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text('Clear transfer history?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('CANCEL')
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('CLEAR')
          )
        ]
      )
    );
    if (clear == true) {
      final allRow = await TransferHistoryService.instance.getAllTransferHistory();
      final allIds = allRow.map((val) => val['id'] as String).toList();
      await TransferHistoryService.instance.deleteTransferHistory(allIds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer history cleared'),)
        );
      }
    }
  }

  Future<void> _editDeviceName() async {
    final controller = TextEditingController(text: _deviceName);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text('Device name', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter a name',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save')
          )
        ],
      )
    );
    if (result != null) {
      await DeviceNameService.setCustomDeviceName(result);
      await _loadDeviceName();
    }
  }

  Future<void> _loadAnimationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final allowed = prefs.getBool('animation_enabled') ?? true;
    if (mounted) setState(() => _animationEnabled = allowed);
  }

  Future<void> _setAnimationPreference(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('animation_enabled', val);
    setState(() => _animationEnabled = val);
  }

  Future<void> _loadCacheSize() async {
    final bytes = await CacheService.getCacheSizeInBytes();
    if (mounted) {
      setState(() {
        _cacheSize = bytes >= 1024 * 1024
          ? '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB'
          : '${(bytes / 1024).toStringAsFixed(2)} KB';
      });
    }
  }

  Future<void> _loadInfoAbtApp() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = '${info.version} ');
  }

  Future<void> _clearCache() async {
    await CacheService.clearCache();
    await _loadCacheSize();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared'),)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 24,),
              _sectionHeader('General settings'),
              _settingsRowTile(
                title:'Device name',
                subtitle: _deviceName,
                trailing: _actionButton(
                  'Change',
                  _editDeviceName,
                )
              ),
              _anotherTile(
                title: 'Animations',
                value: _animationEnabled,
                onChanged: _setAnimationPreference
              ),
              _settingsRowTile(
                title: 'Clear transfer history',
                trailing: _actionButton(
                  'Clear',
                  _clearTransferHistory,
                )
              ),

              _settingsRowTile(
                title: 'Clear cache',
                subtitle: _cacheSize,
                trailing: _actionButton(
                  'Clear',
                  _clearCache,
                )
              ),

              const SizedBox(height: 24),
              _sectionHeader('About'),
              _settingsRowTile(
                title: 'Version',
                subtitle: _appVersion,
              )
            ],
          )
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      )
    )
  );

  Widget _settingsRowTile({required String title, String? subtitle, Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  )
              ],
            )
          ),
          trailing ?? const SizedBox.shrink()        
        ],
      ),
    );
  }

  Widget _anotherTile({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14))
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(value: value, onChanged: onChanged, activeThumbColor: const Color(0xFF258CFA),
            )
          )
        ]
      )
    );
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF258CFA),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}