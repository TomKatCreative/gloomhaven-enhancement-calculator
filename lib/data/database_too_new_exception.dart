/// Thrown when the database file was written by a newer version of the app
/// (its schema version is higher than this build supports).
///
/// The app refuses to open it rather than deleting it, so updating the app
/// gets the user's data back.
class DatabaseTooNewException implements Exception {
  const DatabaseTooNewException({required this.found, required this.supported});

  /// The schema version stored in the file.
  final int found;

  /// The highest schema version this build can open.
  final int supported;

  @override
  String toString() =>
      'Database schema v$found is newer than this app supports (v$supported).';
}
