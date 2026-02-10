// Database table name
const String tableCampaigns = 'Campaigns';

const String columnCampaignId = '_id';
const String columnCampaignWorldId = 'WorldId';
const String columnCampaignName = 'Name';
const String columnCampaignReputation = 'Reputation';
const String columnCampaignCreatedAt = 'CreatedAt';

/// Minimum reputation value.
const int minReputation = -20;

/// Maximum reputation value.
const int maxReputation = 20;

/// A party/campaign within a [World].
///
/// A [Campaign] tracks party-level state: reputation and which characters
/// are assigned to this party. Multiple campaigns can exist in a single world.
class Campaign {
  String id;
  String worldId;
  String name;
  int reputation;
  DateTime? createdAt;

  Campaign({
    required this.id,
    required this.worldId,
    required this.name,
    this.reputation = 0,
    this.createdAt,
  });

  Campaign.fromMap(Map<String, dynamic> map)
    : id = map[columnCampaignId],
      worldId = map[columnCampaignWorldId],
      name = map[columnCampaignName],
      reputation = map[columnCampaignReputation] ?? 0,
      createdAt = map[columnCampaignCreatedAt] != null
          ? DateTime.tryParse(map[columnCampaignCreatedAt])
          : null;

  Map<String, dynamic> toMap() => {
    columnCampaignId: id,
    columnCampaignWorldId: worldId,
    columnCampaignName: name,
    columnCampaignReputation: reputation,
  };
}
