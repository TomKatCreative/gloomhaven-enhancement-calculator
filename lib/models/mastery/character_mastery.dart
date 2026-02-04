import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';

const String tableCharacterMasteries = 'CharacterMasteries';
const String columnAssociatedMasteryId = 'MasteryID';
const String columnCharacterMasteryAchieved = 'MasteryAchieved';

class CharacterMastery {
  late String associatedCharacterUuid;
  late String associatedMasteryId;
  bool characterMasteryAchieved = false;

  CharacterMastery(
    this.associatedCharacterUuid,
    this.associatedMasteryId,
    this.characterMasteryAchieved,
  );

  CharacterMastery.fromMap(Map<String, dynamic> map) {
    associatedCharacterUuid = map[columnAssociatedCharacterUuid];
    associatedMasteryId = map[columnAssociatedMasteryId];
    characterMasteryAchieved = map[columnCharacterMasteryAchieved] == 1;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnAssociatedCharacterUuid: associatedCharacterUuid,
      columnAssociatedMasteryId: associatedMasteryId,
      columnCharacterMasteryAchieved: characterMasteryAchieved ? 1 : 0,
    };
    return map;
  }
}
