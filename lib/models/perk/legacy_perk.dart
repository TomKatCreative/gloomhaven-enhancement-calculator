const String tablePerks = 'PerksTable';
const String columnPerkId = '_id';
const String columnPerkClass = 'Class';
const String columnPerkDetails = 'Details';
const String columnPerkIsGrouped = 'IsGrouped';

class Perk {
  int? perkId;
  late String perkClassCode;
  late int numOfPerks;
  late String perkDetails;
  late bool perkIsGrouped = false;

  Perk(
    this.perkClassCode,
    this.numOfPerks,
    this.perkDetails, {
    this.perkIsGrouped = false,
  });

  Perk.fromMap(Map<String, dynamic> map) {
    perkId = map[columnPerkId];
    perkClassCode = map[columnPerkClass];
    perkDetails = map[columnPerkDetails];
    perkIsGrouped = map[columnPerkIsGrouped] == 1;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnPerkId: perkId,
      columnPerkClass: perkClassCode,
      columnPerkDetails: perkDetails,
      columnPerkIsGrouped: perkIsGrouped ? 1 : 0,
    };
    return map;
  }
}
