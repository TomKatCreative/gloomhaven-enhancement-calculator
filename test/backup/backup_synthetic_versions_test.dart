import 'package:flutter_test/flutter_test.dart';

import '../migration/harness/ffi.dart';
import '../migration/suites/backup_synthetic_versions_suite.dart';

void main() {
  setUpAll(useFfiSqlite);
  defineSyntheticBackupTests();
}
