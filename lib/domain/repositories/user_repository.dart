import '../../models/user_model.dart';

/// User profile contract.
abstract class UserRepository {
  /// Real-time stream of all profiles (ordered by user name).
  Stream<List<UsersModel>> watchUsers();

  /// One-shot fetch of a single profile by user name.
  Future<UsersModel?> getUserByName(String userName);

  /// Creates a profile row for the given user. Upserts by id when available.
  Future<void> createUser(UsersModel user);

  /// Updates an existing profile identified by [userName].
  Future<void> updateUser(String userName, UsersModel updatedUser);
}
