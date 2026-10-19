import 'package:flutter_test/flutter_test.dart';

import 'harness/ffi.dart';
import 'suites/schema_parity_suite.dart';

void main() {
  setUpAll(useFfiSqlite);
  defineSchemaParityTests();
}
