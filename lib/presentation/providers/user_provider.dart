import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserProvider(this._userRepository);

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUser => _currentUser != null;

  // Initialize user (get from storage or create new)
  Future<void> initUser() async {
    _setLoading(true);
    try {
      // Try to get user with ID 1 (for simplicity in this MVP)
      _currentUser = await _userRepository.getUser(1);
      
      // If no user exists, create a default one
      if (_currentUser == null) {
        _currentUser = await _userRepository.createUser('User');
      }
      _setError(null);
    } catch (e) {
      _setError('Failed to initialize user: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update user name
  Future<void> updateUserName(String name) async {
    if (_currentUser == null) return;
    
    _setLoading(true);
    try {
      _currentUser = await _userRepository.updateUser(
        _currentUser!.copyWith(name: name)
      );
      _setError(null);
    } catch (e) {
      _setError('Failed to update user name: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Add XP to user
  Future<void> addXp(int xpAmount) async {
    if (_currentUser == null) return;
    
    _setLoading(true);
    try {
      _currentUser = await _userRepository.addXp(_currentUser!.id, xpAmount);
      _setError(null);
    } catch (e) {
      _setError('Failed to add XP: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update total sport hours
  Future<void> updateTotalSportHours(double additionalHours) async {
    if (_currentUser == null) return;
    
    _setLoading(true);
    try {
      _currentUser = await _userRepository.updateTotalSportHours(
        _currentUser!.id, 
        additionalHours
      );
      _setError(null);
    } catch (e) {
      _setError('Failed to update sport hours: ${e.toString()}');
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