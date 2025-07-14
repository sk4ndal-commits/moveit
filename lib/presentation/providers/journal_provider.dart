import 'package:flutter/foundation.dart';
import '../../domain/entities/journal.dart';
import '../../domain/repositories/journal_repository.dart';

class JournalProvider with ChangeNotifier {
  final JournalRepository _journalRepository;
  
  List<Journal> _journals = [];
  bool _isLoading = false;
  String? _error;
  int? _currentActivityId;
  int? _currentUserId;

  JournalProvider(this._journalRepository);

  // Getters
  List<Journal> get journals => _journals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set current activity ID and load journals for that activity
  void setActivityId(int activityId) {
    _currentActivityId = activityId;
    loadJournalsForActivity();
  }

  // Set current user ID and load all journals for that user
  void setUserId(int userId) {
    _currentUserId = userId;
    loadJournalsForUser();
  }

  // Load journals for current activity
  Future<void> loadJournalsForActivity() async {
    if (_currentActivityId == null) return;
    
    _setLoading(true);
    try {
      _journals = await _journalRepository.getJournalsByActivity(_currentActivityId!);
      _setError(null);
    } catch (e) {
      _setError('Failed to load journals: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load all journals for current user
  Future<void> loadJournalsForUser() async {
    if (_currentUserId == null) return;
    
    _setLoading(true);
    try {
      _journals = await _journalRepository.getJournalsByUser(_currentUserId!);
      _setError(null);
    } catch (e) {
      _setError('Failed to load journals: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new journal entry
  Future<Journal?> createJournal({
    required int activityId,
    required String content,
    required String mood,
  }) async {
    _setLoading(true);
    try {
      final journal = Journal(
        id: 0, // Will be replaced by the database
        activityId: activityId,
        content: content,
        mood: mood,
        createdAt: DateTime.now(),
      );
      
      final createdJournal = await _journalRepository.createJournal(journal);
      
      // Reload journals to update the list
      if (_currentActivityId != null) {
        await loadJournalsForActivity();
      } else if (_currentUserId != null) {
        await loadJournalsForUser();
      }
      
      _setError(null);
      return createdJournal;
    } catch (e) {
      _setError('Failed to create journal: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing journal entry
  Future<Journal?> updateJournal(Journal journal) async {
    _setLoading(true);
    try {
      final updatedJournal = await _journalRepository.updateJournal(journal);
      
      // Reload journals to update the list
      if (_currentActivityId != null) {
        await loadJournalsForActivity();
      } else if (_currentUserId != null) {
        await loadJournalsForUser();
      }
      
      _setError(null);
      return updatedJournal;
    } catch (e) {
      _setError('Failed to update journal: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a journal entry
  Future<bool> deleteJournal(int journalId) async {
    _setLoading(true);
    try {
      await _journalRepository.deleteJournal(journalId);
      
      // Reload journals to update the list
      if (_currentActivityId != null) {
        await loadJournalsForActivity();
      } else if (_currentUserId != null) {
        await loadJournalsForUser();
      }
      
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to delete journal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    if (errorMessage != null) {
      notifyListeners();
    }
  }
}