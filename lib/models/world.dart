import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

// Database table name
const String tableWorlds = 'Worlds';

const String columnWorldId = '_id';
const String columnWorldName = 'Name';
const String columnWorldEdition = 'Edition';
const String columnWorldProsperityCheckmarks = 'ProsperityCheckmarks';
const String columnWorldDonatedGold = 'DonatedGold';
const String columnWorldCreatedAt = 'CreatedAt';

/// Prosperity level thresholds by edition.
///
/// Each list maps prosperity level (index) to the minimum checkmarks required.
/// Level 1 starts at 0 checkmarks; level 9 requires the most.
const Map<GameEdition, List<int>> prosperityThresholds = {
  GameEdition.gloomhaven: [0, 5, 10, 16, 23, 31, 40, 51, 65],
  GameEdition.gloomhaven2e: [0, 5, 10, 16, 23, 31, 40, 51, 65],
  GameEdition.frosthaven: [0, 5, 10, 16, 23, 31, 40, 51, 65],
};

/// A persistent game world with prosperity tracking.
///
/// A [World] represents a single playthrough's persistent state,
/// including prosperity checkmarks and donated gold. Multiple
/// [Campaign]s (parties) can exist within a single world.
class World {
  String id;
  String name;
  GameEdition edition;
  int prosperityCheckmarks;
  int donatedGold;
  DateTime? createdAt;

  World({
    required this.id,
    required this.name,
    required this.edition,
    this.prosperityCheckmarks = 0,
    this.donatedGold = 0,
    this.createdAt,
  });

  World.fromMap(Map<String, dynamic> map)
    : id = map[columnWorldId],
      name = map[columnWorldName],
      edition = GameEdition.values.firstWhere(
        (e) => e.name == map[columnWorldEdition],
      ),
      prosperityCheckmarks = map[columnWorldProsperityCheckmarks] ?? 0,
      donatedGold = map[columnWorldDonatedGold] ?? 0,
      createdAt = map[columnWorldCreatedAt] != null
          ? DateTime.tryParse(map[columnWorldCreatedAt])
          : null;

  Map<String, dynamic> toMap() => {
    columnWorldId: id,
    columnWorldName: name,
    columnWorldEdition: edition.name,
    columnWorldProsperityCheckmarks: prosperityCheckmarks,
    columnWorldDonatedGold: donatedGold,
  };

  /// Computes the current prosperity level (1-9) from checkmarks.
  int get prosperityLevel {
    final thresholds = prosperityThresholds[edition]!;
    int level = 1;
    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (prosperityCheckmarks >= thresholds[i]) {
        level = i + 1;
        break;
      }
    }
    return level;
  }

  /// Maximum prosperity level for the edition.
  int get maxProsperityLevel => prosperityThresholds[edition]!.length;

  /// Checkmarks required to reach the next prosperity level,
  /// or null if already at max.
  int? get checkmarksForNextLevel {
    final thresholds = prosperityThresholds[edition]!;
    final level = prosperityLevel;
    if (level >= thresholds.length) return null;
    return thresholds[level];
  }

  /// Checkmarks required for the current prosperity level.
  int get checkmarksForCurrentLevel {
    final thresholds = prosperityThresholds[edition]!;
    return thresholds[prosperityLevel - 1];
  }
}
