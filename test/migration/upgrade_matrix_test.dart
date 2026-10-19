import 'package:flutter_test/flutter_test.dart';

import 'harness/ffi.dart';
import 'suites/upgrade_matrix_suite.dart';

void main() {
  setUpAll(useFfiSqlite);
  defineUpgradeMatrixTests();
}
