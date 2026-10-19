import 'package:flutter_test/flutter_test.dart';

import 'harness/ffi.dart';
import 'suites/migration_idempotence_suite.dart';

void main() {
  setUpAll(useFfiSqlite);
  defineIdempotenceTests();
}
