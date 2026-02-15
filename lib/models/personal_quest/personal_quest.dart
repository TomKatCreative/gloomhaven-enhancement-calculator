/// Personal Quest model representing a retirement goal card.
///
/// Each [PersonalQuest] has one or more [PersonalQuestRequirement]s that must
/// be fulfilled for a character to retire. Quests are edition-specific
/// (e.g., Gloomhaven, Frosthaven) and may unlock a new class or envelope.
///
/// ## Database Columns
///
/// The `column*` constants define SQLite column names for the
/// PersonalQuests definition table. Requirement data and unlock info
/// are stored in [PersonalQuestsRepository], not in the database.
///
/// See also:
/// - [PersonalQuestsRepository] for static quest definitions
/// - [Character.personalQuestId] for the character-quest association
library;

import 'dart:convert';

import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

// Database table and column constants
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
  late GameEdition edition;
  List<PersonalQuestRequirement> requirements;
  String? unlockClassCode;
  String? unlockEnvelope;

  /// Secondary card number for editions with dual numbering (e.g., Frosthaven
  /// cards have both an edition-specific number 1-23 and an asset number).
  /// Repository-only — not stored in the database.
  int? altNumber;

  PersonalQuest({
    required this.id,
    required this.number,
    required this.title,
    required this.edition,
    this.requirements = const [],
    this.unlockClassCode,
    this.unlockEnvelope,
    this.altNumber,
  });

  PersonalQuest.fromMap(Map<String, dynamic> map) : requirements = const [] {
    id = map[columnPersonalQuestId] as String;
    number = map[columnPersonalQuestNumber] as int;
    title = map[columnPersonalQuestTitle] as String;
    edition = GameEdition.values.byName(
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
  /// Shows both numbers when [altNumber] is set (e.g., "04 (584)"),
  /// otherwise just the primary number (e.g., "510").
  String get displayNumber => altNumber != null
      ? '${number.toString().padLeft(2, '0')} ($altNumber)'
      : '$number';

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
