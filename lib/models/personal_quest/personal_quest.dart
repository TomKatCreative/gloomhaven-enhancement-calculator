/// Personal Quest model representing a retirement goal card.
///
/// Each [PersonalQuest] has one or more [PersonalQuestRequirement]s that must
/// be fulfilled for a character to retire. Quests are edition-specific
/// (e.g., Gloomhaven, Frosthaven) and may unlock a new class or envelope.
///
/// Quest definitions are loaded from [PersonalQuestsRepository] at runtime.
/// Characters store their assigned quest ID and progress directly in the
/// Characters table.
///
/// See also:
/// - [PersonalQuestsRepository] for static quest definitions
/// - [Character.personalQuestId] for the character-quest association
library;

import 'dart:convert';

/// The source edition/expansion for a personal quest.
///
/// Separate from [GameEdition] which governs game rules (enhancement costs,
/// starting gold, etc.). This enum is used purely for quest grouping and
/// display in the quest selector UI.
enum PersonalQuestEdition {
  gloomhaven,
  frosthaven,
  crimsonScales,
  trailOfAshes;

  String get displayName => switch (this) {
    gloomhaven => 'Gloomhaven',
    frosthaven => 'Frosthaven',
    crimsonScales => 'Crimson Scales',
    trailOfAshes => 'Trail of Ashes',
  };
}

// Legacy database table/column constants.
// The PersonalQuestsTable was dropped in v19 — definitions now come from
// PersonalQuestsRepository. These constants are kept for historical migration
// compatibility (database_migrations.dart v18).
const String tablePersonalQuests = 'PersonalQuestsTable';
const String columnPersonalQuestId = '_id';
const String columnPersonalQuestNumber = 'Number';
const String columnPersonalQuestTitle = 'Title';
const String columnPersonalQuestEdition = 'Edition';

/// A personal quest card with retirement requirements.
///
/// Quests are identified by [id] (e.g., "pq_gh_510") and belong to a specific
/// [edition]. Each quest has one or more [requirements] and may unlock a
/// class ([unlockClassCode]) or envelope ([unlockEnvelope]) upon completion.
class PersonalQuest {
  late String id;
  late int number;
  late String title;
  late PersonalQuestEdition edition;
  List<PersonalQuestRequirement> requirements;
  String? unlockClassCode;
  String? unlockEnvelope;

  /// Secondary card number for editions with dual numbering (e.g., Frosthaven
  /// cards have both an edition-specific number 1-23 and an asset number).
  int? altNumber;

  /// When set, [displayNumber] returns this value instead of the computed
  /// number string. Used for quests with non-numeric card identifiers
  /// (e.g., "AA-001" for Crimson Scales add-on classes).
  String? displayNumberOverride;

  PersonalQuest({
    required this.id,
    required this.number,
    required this.title,
    required this.edition,
    this.requirements = const [],
    this.unlockClassCode,
    this.unlockEnvelope,
    this.altNumber,
    this.displayNumberOverride,
  });

  PersonalQuest.fromMap(Map<String, dynamic> map) : requirements = const [] {
    id = map[columnPersonalQuestId] as String;
    number = map[columnPersonalQuestNumber] as int;
    title = map[columnPersonalQuestTitle] as String;
    edition = PersonalQuestEdition.values.byName(
      map[columnPersonalQuestEdition] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    columnPersonalQuestId: id,
    columnPersonalQuestNumber: number,
    columnPersonalQuestTitle: title,
    columnPersonalQuestEdition: edition.name,
  };

  /// Display string for the card number(s).
  ///
  /// Returns [displayNumberOverride] if set (e.g., "AA-001"), otherwise
  /// shows both numbers when [altNumber] is set (e.g., "04 (584)"),
  /// or just the primary number (e.g., "510").
  String get displayNumber =>
      displayNumberOverride ??
      (altNumber != null
          ? '${number.toString().padLeft(2, '0')} ($altNumber)'
          : '$number');

  /// Display string combining number(s) and title, e.g., "510 - Seeker of Xorn"
  /// or "01/581 - The Study of Plants".
  String get displayName => '$displayNumber - $title';
}

/// A single requirement within a personal quest.
///
/// Each requirement has a text [description] and a numeric [target] count.
/// For binary requirements (e.g., "Complete Scenario 52 chain"), the target
/// is 1.
class PersonalQuestRequirement {
  final String description;
  final int target;

  const PersonalQuestRequirement({
    required this.description,
    required this.target,
  });
}

/// Encodes personal quest progress as a JSON string for database storage.
String encodeProgress(List<int> progress) => jsonEncode(progress);

/// Decodes personal quest progress from a JSON string.
List<int> decodeProgress(String json) {
  if (json.isEmpty || json == '[]') return [];
  return List<int>.from(jsonDecode(json) as List);
}
