import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

// Legacy database table/column constants.
// The PerksTable was dropped in v19 — definitions now come from
// PerksRepository. These constants are kept for historical migration
// compatibility (database_migrations.dart v5-v17).
const String tablePerks = 'PerksTable';
const String columnPerkId = '_id';
const String columnPerkClass = 'Class';
const String columnPerkDetails = 'Details';
const String columnPerkIsGrouped = 'IsGrouped';
const String columnPerkVariant = 'Variant';

class Perk {
  late String perkId;
  late String classCode;
  late int quantity;
  late String perkDetails;
  bool grouped = false;
  Variant variant = Variant.base;

  /// Stable identity number for this perk within its class+variant group.
  ///
  /// Used to generate perk IDs that are independent of list position.
  /// Must be unique within each (classCode, variant) pair.
  final int number;

  Perk(
    this.number,
    this.perkDetails, {
    this.quantity = 1,
    this.grouped = false,
  });

  Map<String, dynamic> toMap(String index) {
    var map = <String, dynamic>{
      columnPerkId: '${classCode}_${variant.name}_$index',
      columnPerkClass: classCode,
      columnPerkDetails: perkDetails,
      columnPerkIsGrouped: grouped ? 1 : 0,
      columnPerkVariant: variant.name,
    };
    return map;
  }
}

class Perks {
  Perks(this.perks, {required this.variant});

  List<Perk> perks;
  Variant variant;
}
