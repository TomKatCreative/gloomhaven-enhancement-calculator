/// Thrown when a backup file is rejected before anything is restored.
///
/// Every check that can throw this runs before the database or
/// SharedPreferences are touched, so the user's data is unchanged.
class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}
