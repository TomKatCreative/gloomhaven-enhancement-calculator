const String tableCharacterPerks = 'CharacterPerks';
const String columnAssociatedCharacterUuid = 'CharacterUuid';
const String columnAssociatedPerkId = 'PerkID';
const String columnCharacterPerkIsSelected = 'IsSelected';

class CharacterPerk {
  late String associatedCharacterUuid;
  late String associatedPerkId;
  bool characterPerkIsSelected = false;

  CharacterPerk(
    this.associatedCharacterUuid,
    this.associatedPerkId,
    this.characterPerkIsSelected,
  );

  CharacterPerk.fromMap(Map<String, dynamic> map) {
    associatedCharacterUuid = map[columnAssociatedCharacterUuid];
    associatedPerkId = map[columnAssociatedPerkId];
    characterPerkIsSelected = map[columnCharacterPerkIsSelected] == 1;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnAssociatedCharacterUuid: associatedCharacterUuid,
      columnAssociatedPerkId: associatedPerkId,
      columnCharacterPerkIsSelected: characterPerkIsSelected ? 1 : 0,
    };
    return map;
  }
}
