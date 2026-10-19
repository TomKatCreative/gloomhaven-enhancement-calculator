/// Known data bugs the harness exposes. Each skipped test names one of these;
/// details, repro commands and observed failures are in
/// docs/known_data_bugs.md. Run the skipped tests with:
///
///   flutter test --run-skipped test/migration test/backup
const Map<String, String> knownBugs = {
  'BUG-001': 'Characters created before v7 never get CharacterMasteries rows',
  'BUG-002':
      'v7 masteries are remapped to {class}_base_N IDs the app never shows',
  'BUG-006': 'restoreBackup never validates perk/mastery IDs',
};

/// A `skip:` reason pointing at the bug's entry in the docs.
String knownBug(String id) {
  final summary = knownBugs[id];
  if (summary == null) throw ArgumentError('Unknown bug id $id');
  return '$id: $summary — see docs/known_data_bugs.md';
}
