/// Known data bugs the harness exposes. Each skipped test names one of these;
/// details, repro commands and observed failures are in
/// docs/known_data_bugs.md. Run the skipped tests with:
///
///   flutter test --run-skipped test/migration test/backup
///
/// Empty while no known bug is open; add an entry when a new one is found.
const Map<String, String> knownBugs = {};

/// A `skip:` reason pointing at the bug's entry in the docs.
String knownBug(String id) {
  final summary = knownBugs[id];
  if (summary == null) throw ArgumentError('Unknown bug id $id');
  return '$id: $summary — see docs/known_data_bugs.md';
}
