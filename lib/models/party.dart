import 'dart:convert';

// Database table name
const String tableParties = 'Parties';

const String columnPartyId = '_id';
const String columnPartyCampaignId = 'CampaignId';
const String columnPartyName = 'Name';
const String columnPartyReputation = 'Reputation';
const String columnPartyCreatedAt = 'CreatedAt';
const String columnPartyLocation = 'Location';
const String columnPartyNotes = 'Notes';
const String columnPartyAchievements = 'Achievements';

/// Minimum reputation value.
const int minReputation = -20;

/// Maximum reputation value.
const int maxReputation = 20;

/// A party within a [Campaign].
///
/// A [Party] tracks party-level state: reputation, scenario location,
/// notes, achievements, and which characters are assigned to this party.
/// Multiple parties can exist in a single campaign.
class Party {
  String id;
  String campaignId;
  String name;
  int reputation;
  String location;
  String notes;
  List<String> achievements;
  DateTime? createdAt;

  Party({
    required this.id,
    required this.campaignId,
    required this.name,
    this.reputation = 0,
    this.location = '',
    this.notes = '',
    List<String>? achievements,
    this.createdAt,
  }) : achievements = achievements ?? [];

  Party.fromMap(Map<String, dynamic> map)
    : id = map[columnPartyId],
      campaignId = map[columnPartyCampaignId],
      name = map[columnPartyName],
      reputation = map[columnPartyReputation] ?? 0,
      location = map[columnPartyLocation] ?? '',
      notes = map[columnPartyNotes] ?? '',
      achievements = _decodeAchievements(map[columnPartyAchievements]),
      createdAt = map[columnPartyCreatedAt] != null
          ? DateTime.tryParse(map[columnPartyCreatedAt])
          : null;

  Map<String, dynamic> toMap() => {
    columnPartyId: id,
    columnPartyCampaignId: campaignId,
    columnPartyName: name,
    columnPartyReputation: reputation,
    columnPartyLocation: location,
    columnPartyNotes: notes,
    columnPartyAchievements: jsonEncode(achievements),
  };

  /// Shop price modifier derived from reputation.
  ///
  /// Negative values = discount, positive = surcharge.
  int get shopPriceModifier {
    if (reputation >= 19) return -5;
    if (reputation >= 15) return -4;
    if (reputation >= 11) return -3;
    if (reputation >= 7) return -2;
    if (reputation >= 3) return -1;
    if (reputation >= -2) return 0;
    if (reputation >= -6) return 1;
    if (reputation >= -10) return 2;
    if (reputation >= -14) return 3;
    if (reputation >= -18) return 4;
    return 5;
  }

  static List<String> _decodeAchievements(dynamic value) {
    if (value == null || value == '') return [];
    if (value is String) {
      final decoded = jsonDecode(value);
      if (decoded is List) return decoded.cast<String>();
    }
    return [];
  }
}
