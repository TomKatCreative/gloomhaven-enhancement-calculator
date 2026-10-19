import 'package:flutter_test/flutter_test.dart';

import 'harness/ffi.dart';
import 'suites/migration_atomicity_suite.dart';

void main() {
  setUpAll(useFfiSqlite);
  defineAtomicityTests();
}
