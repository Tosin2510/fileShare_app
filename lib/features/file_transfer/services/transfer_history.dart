import 'package:file_share_app/features/file_transfer/models/transfer_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// This service is responsible for keeping track of the transfer hist.
class TransferHistoryService {
  TransferHistoryService._internal();
  static final TransferHistoryService instance = TransferHistoryService._internal();
  Database? _database;
  Future<Database> get _db async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'file_transfer_history.db');
    // I am making use of open database here.
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
            await db.execute(
              '''
              Create table file_transfer_history(
              id TEXT PRIMARY KEY,
              fileName TEXT,
              mimeType TEXT,
              totalBytes INTEGER,
              transferDirection TEXT,
              transferStatus TEXT,
              savedAt TEXT,
              timeStamp INTEGER)
              '''
            );
          },
        );
        return _database!;
      }

// This records the history in the database.
      Future<void> recordSharing(TransferItem item) async {
        final db = await _db;
        await db.insert(
          'file_transfer_history',
          {
            'id': item.id,
            'fileName': item.fileName,
            'mimeType' : item.mimeType,
            'totalBytes' : item.totalBytes,
            'transferDirection': item.direction.name,
            'transferStatus': item.status.name,
            'savedAt' : item.savedPath,
            'timeStamp' : DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm : ConflictAlgorithm.replace,
        );
      }
// Gets transfer history drom the database.
      Future<List<Map<String, dynamic>>> getAllTransferHistory() async {
        final db = await _db;
        return db.query('file_transfer_history', orderBy: 'timeStamp DESC');
      }

      Future<void> deleteTransferHistory(List<String> ids) async {
        final db = await _db;
        await db.delete(
          'file_transfer_history',
          where: 'id IN (${ids.map((_) => '?').join(',')})',
          whereArgs: ids,
        );
      }
}