import '../entities/journal.dart';

abstract class JournalRepository {
  // Get journal entries for a specific activity
  Future<List<Journal>> getJournalsByActivity(int activityId);
  
  // Get journal entry by ID
  Future<Journal?> getJournal(int id);
  
  // Create a new journal entry
  Future<Journal> createJournal(Journal journal);
  
  // Update a journal entry
  Future<Journal> updateJournal(Journal journal);
  
  // Delete a journal entry
  Future<void> deleteJournal(int journalId);
  
  // Get all journal entries for a user (via activities)
  Future<List<Journal>> getJournalsByUser(int userId);
}