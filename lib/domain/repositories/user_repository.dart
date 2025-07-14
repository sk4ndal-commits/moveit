import '../entities/user.dart';

abstract class UserRepository {
  // Get user by ID
  Future<User?> getUser(int id);
  
  // Create a new user
  Future<User> createUser(String name);
  
  // Update user information
  Future<User> updateUser(User user);
  
  // Add XP to user and handle level up if necessary
  Future<User> addXp(int userId, int xpAmount);
  
  // Update total sport hours
  Future<User> updateTotalSportHours(int userId, double additionalHours);
}