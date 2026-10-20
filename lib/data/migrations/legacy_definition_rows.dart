// MIGRATION-ONLY. Do not import outside `database_migrations.dart` and tests.
// Table/column names and row serializers for the Perks, Masteries and
// PersonalQuests definition tables, all dropped in v19. Migrations v8–v18
// still build and rewrite these tables, so the shapes here must stay frozen.

import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';

const String tablePerks = 'PerksTable';
const String columnPerkId = '_id';
const String columnPerkClass = 'Class';
const String columnPerkDetails = 'Details';
const String columnPerkIsGrouped = 'IsGrouped';
const String columnPerkVariant = 'Variant';

const String tableMasteries = 'MasteriesTable';
const String columnMasteryId = '_id';
const String columnMasteryClass = 'Class';
const String columnMasteryDetails = 'Details';
const String columnMasteryVariant = 'Variant';

const String tablePersonalQuests = 'PersonalQuestsTable';
const String columnPersonalQuestId = '_id';
const String columnPersonalQuestNumber = 'Number';
const String columnPersonalQuestTitle = 'Title';
const String columnPersonalQuestEdition = 'Edition';

extension PerkLegacyRow on Perk {
  /// A `PerksTable` row whose ID is `{classCode}_{variant}_{index}`.
  Map<String, dynamic> toLegacyRow(String index) => {
    columnPerkId: '${classCode}_${variant.name}_$index',
    columnPerkClass: classCode,
    columnPerkDetails: perkDetails,
    columnPerkIsGrouped: grouped ? 1 : 0,
    columnPerkVariant: variant.name,
  };
}

extension MasteryLegacyRow on Mastery {
  /// A `MasteriesTable` row whose ID is `{classCode}_{variant}_{index}`.
  Map<String, dynamic> toLegacyRow(String index) => {
    columnMasteryId: '${classCode}_${variant.name}_$index',
    columnMasteryClass: classCode,
    columnMasteryDetails: masteryDetails,
    columnMasteryVariant: variant.name,
  };
}

extension PersonalQuestLegacyRow on PersonalQuest {
  /// A `PersonalQuestsTable` row, seeded by the v18 migration.
  Map<String, dynamic> toLegacyRow() => {
    columnPersonalQuestId: id,
    columnPersonalQuestNumber: number,
    columnPersonalQuestTitle: title,
    columnPersonalQuestEdition: edition.name,
  };
}
