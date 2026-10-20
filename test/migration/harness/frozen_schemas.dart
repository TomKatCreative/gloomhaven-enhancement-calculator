// FROZEN. Do not edit a shipped schema below.
//
// Each [FrozenSchema] is the exact fresh-install DDL an app release created
// for a schema version, copied from git with every Dart constant expanded to
// literal SQL. Nothing here may reference `lib/` constants: renaming a constant
// must never silently change what a historical database looked like.
//
// When the schema version is bumped, freeze the outgoing version here (see
// docs/database_migration_testing.md#adding-a-migration). The tripwire test
// fails until every version below the current one is covered.

class FrozenSchema {
  const FrozenSchema({
    required this.id,
    required this.versions,
    required this.source,
    required this.statements,
  });

  /// Short name used in test descriptions, e.g. `v01-04`.
  final String id;

  /// Schema versions whose fresh install produced exactly this DDL.
  final Set<int> versions;

  /// Provenance: release and the command the DDL was copied from.
  final String source;

  final List<String> statements;
}

/// v1–v4 (app 3.0.0 – 3.2.1). Identical DDL across all four versions.
const _v01to04 = FrozenSchema(
  id: 'v01-04',
  versions: {1, 2, 3, 4},
  source:
      '1524e9a (v1, 3.0.0), 19270f4 (v2), e611670 (v3), 863d276 (v4, 3.2.1): '
      'git show <commit>:lib/data/database_helpers.dart  _onCreate',
  statements: [
    '''
CREATE TABLE Characters (
  _id INTEGER PRIMARY KEY,
  Name TEXT NOT NULL,
  ClassCode TEXT NOT NULL,
  ClassColor TEXT NOT NULL,
  ClassIcon TEXT NOT NULL,
  ClassRace TEXT NOT NULL,
  ClassName TEXT NOT NULL,
  PreviousRetirements INTEGER NOT NULL,
  XP INTEGER NOT NULL,
  Gold INTEGER NOT NULL,
  Notes TEXT NOT NULL,
  CheckMarks INTEGER NOT NULL,
  IsRetired BOOL NOT NULL
)''',
    '''
CREATE TABLE PerksTable (
  _id INTEGER PRIMARY KEY,
  Class TEXT NOT NULL,
  Details TEXT NOT NULL
)''',
    '''
CREATE TABLE CharacterPerks (
  CharacterID INTEGER,
  PerkID INTEGER,
  IsSelected BOOLEAN
)''',
  ],
);

/// v5–v6 (app 3.2.5 – 3.6.3+86). UUIDs; no resources or masteries.
const _v05to06 = FrozenSchema(
  id: 'v05-06',
  versions: {5, 6},
  source:
      '19581f1 (v5, 3.2.5), b133d58 (v6, 3.6.3+86): '
      'git show <commit>:lib/data/database_helpers.dart  _onCreate',
  statements: _v05to06Statements,
);

/// Late v6 development builds (e186195, 3.6.3+90, May 2022) added mastery
/// tables to the fresh install without bumping the version. Not a known
/// production release; covered by a characterization test (RISK-003), not by
/// [coveredVersions].
const v06LateDev = FrozenSchema(
  id: 'v06-late-dev',
  versions: {6},
  source: 'e186195 (3.6.3+90): git show e186195:lib/data/database_helpers.dart',
  statements: [
    ..._v05to06Statements,
    '''
CREATE TABLE MasteriesTable (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  Class TEXT NOT NULL,
  Details TEXT NOT NULL
)''',
    '''
CREATE TABLE CharacterMasteries (
  CharacterUuid TEXT NOT NULL,
  MasteryID INTEGER NOT NULL,
  MasteryProgress INTEGER NOT NULL
)''',
  ],
);

const _v05to06Statements = [
  '''
CREATE TABLE Characters (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  Uuid TEXT NOT NULL,
  Name TEXT NOT NULL,
  ClassCode TEXT NOT NULL,
  PreviousRetirements INTEGER NOT NULL,
  XP INTEGER NOT NULL,
  Gold INTEGER NOT NULL,
  Notes TEXT NOT NULL,
  CheckMarks INTEGER NOT NULL,
  IsRetired BOOL NOT NULL
)''',
  '''
CREATE TABLE PerksTable (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  Class TEXT NOT NULL,
  Details TEXT NOT NULL,
  IsGrouped BOOL NOT NULL
)''',
  '''
CREATE TABLE CharacterPerks (
  CharacterUuid TEXT NOT NULL,
  PerkID INTEGER NOT NULL,
  IsSelected BOOL NOT NULL
)''',
];

/// v7 (app 4.0.0 – 4.1.0). Resources, masteries, integer definition IDs.
const _v07 = FrozenSchema(
  id: 'v07',
  versions: {7},
  source:
      'd297c90 (4.0.0+187) .. bd37c5a^ (identical): '
      'git show d297c90:lib/data/database_helpers.dart  _onCreate',
  statements: [
    '''
CREATE TABLE Characters (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  Uuid TEXT NOT NULL,
  Name TEXT NOT NULL,
  ClassCode TEXT NOT NULL,
  PreviousRetirements INTEGER NOT NULL,
  XP INTEGER NOT NULL,
  Gold INTEGER NOT NULL,
  Notes TEXT NOT NULL,
  CheckMarks INTEGER NOT NULL,
  IsRetired BOOL NOT NULL,
  ResourceHide INTEGER NOT NULL,
  ResourceMetal INTEGER NOT NULL,
  ResourceWood INTEGER NOT NULL,
  ResourceArrowVine INTEGER NOT NULL,
  ResourceAxeNut INTEGER NOT NULL,
  ResourceRockRoot INTEGER NOT NULL,
  ResourceFlameFruit INTEGER NOT NULL,
  ResourceCorpseCap INTEGER NOT NULL,
  ResourceSnowThistle INTEGER NOT NULL
)''',
    '''
CREATE TABLE PerksTable (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  Class TEXT NOT NULL,
  Details TEXT NOT NULL,
  IsGrouped BOOL NOT NULL
)''',
    '''
CREATE TABLE CharacterPerks (
  CharacterUuid TEXT NOT NULL,
  PerkID INTEGER NOT NULL,
  IsSelected BOOL NOT NULL
)''',
    '''
CREATE TABLE MasteriesTable (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  Class TEXT NOT NULL,
  Details TEXT NOT NULL
)''',
    '''
CREATE TABLE CharacterMasteries (
  CharacterUuid TEXT NOT NULL,
  MasteryID INTEGER NOT NULL,
  MasteryAchieved BOOL NOT NULL
)''',
  ],
);

const _metaData = '''
CREATE TABLE MetaData (
  DatabaseVersion INTEGER NOT NULL,
  AppVersion TEXT NOT NULL,
  AppBuildNumber INTEGER NOT NULL,
  LastUpdated DATETIME DEFAULT CURRENT_TIMESTAMP
)''';

const _v08CharacterColumns = '''
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  Uuid TEXT NOT NULL,
  Name TEXT NOT NULL,
  ClassCode TEXT NOT NULL,
  PreviousRetirements INTEGER NOT NULL,
  XP INTEGER NOT NULL,
  Gold INTEGER NOT NULL,
  Notes TEXT NOT NULL,
  CheckMarks INTEGER NOT NULL,
  IsRetired BOOL NOT NULL,
  ResourceHide INTEGER NOT NULL,
  ResourceMetal INTEGER NOT NULL,
  ResourceWood INTEGER NOT NULL,
  ResourceArrowVine INTEGER NOT NULL,
  ResourceAxeNut INTEGER NOT NULL,
  ResourceRockRoot INTEGER NOT NULL,
  ResourceFlameFruit INTEGER NOT NULL,
  ResourceCorpseCap INTEGER NOT NULL,
  ResourceSnowThistle INTEGER NOT NULL,
  Variant TEXT NOT NULL''';

const _textIdTables = [
  '''
CREATE TABLE PerksTable (
  _id TEXT PRIMARY KEY,
  Class TEXT NOT NULL,
  Details TEXT NOT NULL,
  IsGrouped BOOL NOT NULL DEFAULT 0,
  Variant TEXT NOT NULL
)''',
  '''
CREATE TABLE CharacterPerks (
  CharacterUuid TEXT NOT NULL,
  PerkID TEXT NOT NULL,
  IsSelected BOOL NOT NULL
)''',
  '''
CREATE TABLE MasteriesTable (
  _id TEXT PRIMARY KEY,
  Class TEXT NOT NULL,
  Details TEXT NOT NULL,
  Variant TEXT NOT NULL
)''',
  '''
CREATE TABLE CharacterMasteries (
  CharacterUuid TEXT NOT NULL,
  MasteryID TEXT NOT NULL,
  MasteryAchieved BOOL NOT NULL
)''',
];

/// v8–v17 (app 4.2.0 – 4.4.0). Identical DDL across all these releases.
const _v08to17 = FrozenSchema(
  id: 'v08-17',
  versions: {8, 9, 10, 11, 12, 13, 14, 15, 16, 17},
  source:
      'c57b409 (v8, 4.2.0+268), v4.2.2 (v13), v4.3.0 (v14), v4.3.1 (v15), '
      'v4.3.2 (v16), v4.4.0 (v17); v9–v12 from <next bump>^: '
      'git show <ref>:lib/data/database_helpers.dart  _onCreate/_createTables, '
      'database_migrations.dart createMetaDataTable',
  statements: [
    _metaData,
    'CREATE TABLE Characters (\n$_v08CharacterColumns\n)',
    ..._textIdTables,
  ],
);

/// v18 (app 4.5.0). Personal quests.
const _v18 = FrozenSchema(
  id: 'v18',
  versions: {18},
  source: 'v4.5.0: git show v4.5.0:lib/data/database_helpers.dart',
  statements: [
    _metaData,
    "CREATE TABLE Characters (\n$_v08CharacterColumns,\n"
        "  PersonalQuestId TEXT NOT NULL DEFAULT '',\n"
        "  PersonalQuestProgress TEXT NOT NULL DEFAULT '[]'\n)",
    ..._textIdTables,
    '''
CREATE TABLE PersonalQuestsTable (
  _id TEXT PRIMARY KEY,
  Number INTEGER NOT NULL,
  Title TEXT NOT NULL,
  Edition TEXT NOT NULL
)''',
  ],
);

/// v19 (app 4.5.1 – 4.5.3). Definition tables gone.
const _v19 = FrozenSchema(
  id: 'v19',
  versions: {19},
  source: 'v4.5.3: git show v4.5.3:lib/data/database_helper.dart',
  statements: [
    _metaData,
    "CREATE TABLE Characters (\n$_v08CharacterColumns,\n"
        "  PersonalQuestId TEXT NOT NULL DEFAULT '',\n"
        "  PersonalQuestProgress TEXT NOT NULL DEFAULT '[]'\n)",
    '''
CREATE TABLE CharacterPerks (
  CharacterUuid TEXT NOT NULL,
  PerkID TEXT NOT NULL,
  IsSelected BOOL NOT NULL
)''',
    '''
CREATE TABLE CharacterMasteries (
  CharacterUuid TEXT NOT NULL,
  MasteryID TEXT NOT NULL,
  MasteryAchieved BOOL NOT NULL
)''',
  ],
);

/// v20 (app 4.6.0 – 4.6.1). ShowResources and IsJawsOfTheLion flags. The
/// fresh install declares them without the DEFAULTs that migrated databases
/// get (DRIFT, see `schema_parity_test.dart`).
const _v20 = FrozenSchema(
  id: 'v20',
  versions: {20},
  source: 'v4.6.1: test/fixtures/schema/fresh_current.json at 9be97a3',
  statements: [
    _metaData,
    """
CREATE TABLE Characters (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  Uuid TEXT NOT NULL,
  Name TEXT NOT NULL,
  ClassCode TEXT NOT NULL,
  PreviousRetirements INTEGER NOT NULL,
  XP INTEGER NOT NULL,
  Gold INTEGER NOT NULL,
  Notes TEXT NOT NULL,
  CheckMarks INTEGER NOT NULL,
  IsRetired BOOL NOT NULL,
  ShowResources BOOL NOT NULL,
  IsJawsOfTheLion BOOL NOT NULL,
  ResourceHide INTEGER NOT NULL,
  ResourceMetal INTEGER NOT NULL,
  ResourceWood INTEGER NOT NULL,
  ResourceArrowVine INTEGER NOT NULL,
  ResourceAxeNut INTEGER NOT NULL,
  ResourceRockRoot INTEGER NOT NULL,
  ResourceFlameFruit INTEGER NOT NULL,
  ResourceCorpseCap INTEGER NOT NULL,
  ResourceSnowThistle INTEGER NOT NULL,
  Variant TEXT NOT NULL,
  PersonalQuestId TEXT NOT NULL DEFAULT '',
  PersonalQuestProgress TEXT NOT NULL DEFAULT '[]'
)""",
    '''
CREATE TABLE CharacterPerks (
  CharacterUuid TEXT NOT NULL,
  PerkID TEXT NOT NULL,
  IsSelected BOOL NOT NULL
)''',
    '''
CREATE TABLE CharacterMasteries (
  CharacterUuid TEXT NOT NULL,
  MasteryID TEXT NOT NULL,
  MasteryAchieved BOOL NOT NULL
)''',
  ],
);

const List<FrozenSchema> frozenSchemas = [
  _v01to04,
  _v05to06,
  _v07,
  _v08to17,
  _v18,
  _v19,
  _v20,
];

/// Every schema version a user can upgrade from that has a frozen fixture.
final Set<int> coveredVersions = {for (final s in frozenSchemas) ...s.versions};

FrozenSchema schemaFor(int version) =>
    frozenSchemas.firstWhere((s) => s.versions.contains(version));
