import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

// Legacy database table/column constants.
// The MasteriesTable was dropped in v19 — definitions now come from
// MasteriesRepository. These constants are kept for historical migration
// compatibility (database_migrations.dart v7-v17).
const String tableMasteries = 'MasteriesTable';
const String columnMasteryId = '_id';
const String columnMasteryClass = 'Class';
const String columnMasteryDetails = 'Details';
const String columnMasteryVariant = 'Variant';

class Mastery {
  late String id;
  late String classCode;
  late String masteryDetails;
  Variant variant = Variant.base;

  Mastery({required this.masteryDetails});

  Mastery.fromMap(Map<String, dynamic> map) {
    id = map[columnMasteryId];
    classCode = map[columnMasteryClass];
    masteryDetails = map[columnMasteryDetails];
    variant = Variant.values.firstWhere(
      (element) => element.name == map[columnMasteryVariant],
    );
  }

  Map<String, dynamic> toMap(String index) {
    var map = <String, dynamic>{
      columnMasteryId: '${classCode}_${variant.name}_$index',
      columnMasteryClass: classCode,
      columnMasteryDetails: masteryDetails,
      columnMasteryVariant: variant.name,
    };
    return map;
  }
}

class Masteries {
  Masteries(this.masteries, {this.variant = Variant.base});

  List<Mastery> masteries;
  Variant variant;
}
