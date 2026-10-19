import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Points sqflite at the in-process FFI SQLite for desktop unit tests.
///
/// Kept out of the shared harness so the on-device integration test, which
/// uses the platform SQLite, never pulls in the FFI package.
void useFfiSqlite() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;
}
