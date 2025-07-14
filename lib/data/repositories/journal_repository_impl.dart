import '../../domain/entities/journal.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/database_helper.dart';
import '../models/journal_model.dart';

class JournalRepositoryImpl implements JournalRepository {
  final DatabaseHelper _databaseHelper;

  JournalRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Journal>> getJournalsByActivity(int activityId) async {
    final maps = await _databaseHelper.query(
      DatabaseHelper.journalTable,
      whereClause: 'activityId = ?',
      whereArgs: [activityId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => JournalModel.fromMap(map)).toList();
  }

  @override
  Future<Journal?> getJournal(int id) async {
    final maps = await _databaseHelper.query(
      DatabaseHelper.journalTable,
      whereClause: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return JournalModel.fromMap(maps.first);
  }

  @override
  Future<Journal> createJournal(Journal journal) async {
    // Convert to JournalModel if it's not already
    final journalModel = journal is JournalModel ? journal : JournalModel(
      id: 0, // Will be replaced by the database
      activityId: journal.activityId,
      content: journal.content,
      mood: journal.mood,
      createdAt: journal.createdAt,
    );

    // Insert into database
    final id = await _databaseHelper.insert(
      DatabaseHelper.journalTable,
      journalModel.toMap(),
    );

    // Return the journal with the assigned ID
    return journalModel.copyWith(id: id);
  }

  @override
  Future<Journal> updateJournal(Journal journal) async {
    // Convert to JournalModel if it's not already
    final journalModel = journal is JournalModel ? journal : JournalModel(
      id: journal.id,
      activityId: journal.activityId,
      content: journal.content,
      mood: journal.mood,
      createdAt: journal.createdAt,
    );

    // Update in database
    await _databaseHelper.update(
      DatabaseHelper.journalTable,
      journalModel.toMap(),
      'id = ?',
      [journalModel.id],
    );

    return journalModel;
  }

  @override
  Future<void> deleteJournal(int journalId) async {
    await _databaseHelper.delete(
      DatabaseHelper.journalTable,
      'id = ?',
      [journalId],
    );
  }

  @override
  Future<List<Journal>> getJournalsByUser(int userId) async {
    // This is a more complex query that joins tables
    final sql = '''
      SELECT j.* 
      FROM ${DatabaseHelper.journalTable} j
      INNER JOIN ${DatabaseHelper.activityTable} a ON j.activityId = a.id
      WHERE a.userId = ?
      ORDER BY j.createdAt DESC
    ''';

    final maps = await _databaseHelper.rawQuery(sql, [userId]);
    return maps.map((map) => JournalModel.fromMap(map)).toList();
  }
}