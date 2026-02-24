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
  gloomhaven2e,
  frosthaven,
  crimsonScales,
  trailOfAshes;

  String get displayName => switch (this) {
    gloomhaven => 'Gloomhaven',
    gloomhaven2e => 'Gloomhaven 2e',
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

  /// Display string for the card number.
  ///
  /// Returns [displayNumberOverride] if set (e.g., "AA-001"), otherwise
  /// zero-pads when [altNumber] is set (e.g., "04"), or just the primary
  /// number (e.g., "510").
  String get displayNumber =>
      displayNumberOverride ??
      (altNumber != null ? number.toString().padLeft(2, '0') : '$number');

  /// Display string combining number and title, e.g., "510: Seeker of Xorn"
  /// or "03: Merchant Class".
  String get displayName => '$displayNumber: $title';
}

/// A single requirement within a personal quest.
///
/// Each requirement has a text [description] and a numeric [target] count.
/// For binary requirements (e.g., "Complete Scenario 52 chain"), the target
/// is 1.
///
/// Optional [details] provides supplemental rules text (e.g., how to gain
/// Votes for GH2E quest 537) that can be shown in a bottom sheet.
///
/// When [checklistItems] is provided, the requirement is rendered as a list
/// of checkboxes (one per item). Progress is stored as a bitmask — each bit
/// corresponds to one item. The requirement is complete when the number of
/// checked items ([checkedCount]) reaches [target].
class PersonalQuestRequirement {
  final String description;
  final int target;
  final String? details;
  final List<String>? checklistItems;

  const PersonalQuestRequirement({
    required this.description,
    required this.target,
    this.details,
    this.checklistItems,
  });

  /// Returns the effective progress value for completion checks.
  ///
  /// For checklist requirements, counts the number of set bits in
  /// [rawProgress] (each bit = one checked item). For standard
  /// requirements, returns [rawProgress] unchanged.
  int checkedCount(int rawProgress) {
    if (checklistItems == null) return rawProgress;
    var count = 0;
    var bits = rawProgress;
    while (bits > 0) {
      count += bits & 1;
      bits >>= 1;
    }
    return count;
  }
}

/// Encodes personal quest progress as a JSON string for database storage.
String encodeProgress(List<int> progress) => jsonEncode(progress);

/// Decodes personal quest progress from a JSON string.
List<int> decodeProgress(String json) {
  if (json.isEmpty || json == '[]') return [];
  return List<int>.from(jsonDecode(json) as List);
}
