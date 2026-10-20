const String tableMasteries = 'MasteriesTable';
const String columnMasteryId = '_id';
const String columnMasteryClass = 'Class';
const String columnMasteryDetails = 'Details';

class Mastery {
  int? masteryId;
  late String masteryClassCode;
  late String masteryDetails;

  Mastery({required this.masteryClassCode, required this.masteryDetails});

  Mastery.fromMap(Map<String, dynamic> map) {
    masteryId = map[columnMasteryId];
    masteryClassCode = map[columnMasteryClass];
    masteryDetails = map[columnMasteryDetails];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnMasteryId: masteryId,
      columnMasteryClass: masteryClassCode,
      columnMasteryDetails: masteryDetails,
    };
    return map;
  }
}
