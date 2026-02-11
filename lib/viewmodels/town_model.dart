import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper_interface.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:uuid/uuid.dart';

/// Manages campaign and party state for the Town screen.
///
/// Handles CRUD operations for campaigns and parties, and persists
/// the active campaign/party selection in SharedPrefs.
class TownModel with ChangeNotifier {
  TownModel({required this.databaseHelper});

  final IDatabaseHelper databaseHelper;

  List<Campaign> _campaigns = [];
  List<Party> _parties = [];
  Campaign? _activeCampaign;
  Party? _activeParty;
  bool _isEditMode = false;

  // ── Getters ──

  List<Campaign> get campaigns => List.unmodifiable(_campaigns);
  List<Party> get parties => List.unmodifiable(_parties);
  Campaign? get activeCampaign => _activeCampaign;
  Party? get activeParty => _activeParty;

  bool get isEditMode => _isEditMode;

  set isEditMode(bool value) {
    _isEditMode = value;
    notifyListeners();
  }

  // ── Loading ──

  /// Loads all campaigns from the database and restores active selection.
  Future<void> loadCampaigns() async {
    _campaigns = await databaseHelper.queryAllCampaigns();

    // Restore active campaign from SharedPrefs
    final savedCampaignId = SharedPrefs().activeCampaignId;
    if (savedCampaignId != null) {
      _activeCampaign = _campaigns.cast<Campaign?>().firstWhere(
        (c) => c?.id == savedCampaignId,
        orElse: () => null,
      );
    }

    // Fall back to first campaign if saved one not found
    if (_activeCampaign == null && _campaigns.isNotEmpty) {
      _activeCampaign = _campaigns.first;
      SharedPrefs().activeCampaignId = _activeCampaign!.id;
    }

    // Load parties for active campaign
    if (_activeCampaign != null) {
      await _loadParties();
    }

    notifyListeners();
  }

  /// Loads parties for the active campaign and restores active party.
  Future<void> _loadParties() async {
    if (_activeCampaign == null) {
      _parties = [];
      _activeParty = null;
      return;
    }

    _parties = await databaseHelper.queryParties(_activeCampaign!.id);

    // Restore active party from SharedPrefs
    final savedPartyId = SharedPrefs().activePartyId;
    if (savedPartyId != null) {
      _activeParty = _parties.cast<Party?>().firstWhere(
        (p) => p?.id == savedPartyId,
        orElse: () => null,
      );
    }

    // Fall back to first party if saved one not found
    if (_activeParty == null && _parties.isNotEmpty) {
      _activeParty = _parties.first;
      SharedPrefs().activePartyId = _activeParty!.id;
    }
  }

  // ── Campaign CRUD ──

  /// Creates a new campaign and sets it as active.
  Future<void> createCampaign({
    required String name,
    required GameEdition edition,
    int startingProsperityCheckmarks = 0,
  }) async {
    final campaign = Campaign(
      id: const Uuid().v1(),
      name: name,
      edition: edition,
      prosperityCheckmarks: startingProsperityCheckmarks,
    );

    await databaseHelper.insertCampaign(campaign);
    _campaigns.add(campaign);
    _activeCampaign = campaign;
    SharedPrefs().activeCampaignId = campaign.id;

    // Clear party state for new campaign
    _parties = [];
    _activeParty = null;
    SharedPrefs().activePartyId = null;

    _isEditMode = false;
    notifyListeners();
  }

  /// Sets the active campaign and loads its parties.
  Future<void> setActiveCampaign(Campaign campaign) async {
    _activeCampaign = campaign;
    SharedPrefs().activeCampaignId = campaign.id;
    _activeParty = null;
    SharedPrefs().activePartyId = null;
    await _loadParties();
    _isEditMode = false;
    notifyListeners();
  }

  /// Renames the active campaign.
  Future<void> renameCampaign(String newName) async {
    if (_activeCampaign == null) return;
    _activeCampaign!.name = newName;
    await databaseHelper.updateCampaign(_activeCampaign!);
    notifyListeners();
  }

  /// Deletes the active campaign and all its parties.
  Future<void> deleteActiveCampaign() async {
    if (_activeCampaign == null) return;
    await databaseHelper.deleteCampaign(_activeCampaign!.id);
    _campaigns.remove(_activeCampaign);
    _parties = [];
    _activeParty = null;
    SharedPrefs().activePartyId = null;

    if (_campaigns.isNotEmpty) {
      _activeCampaign = _campaigns.first;
      SharedPrefs().activeCampaignId = _activeCampaign!.id;
      await _loadParties();
    } else {
      _activeCampaign = null;
      SharedPrefs().activeCampaignId = null;
    }

    _isEditMode = false;
    notifyListeners();
  }

  // ── Prosperity ──

  /// Increments prosperity checkmarks by 1.
  Future<void> incrementProsperity() async {
    if (_activeCampaign == null) return;
    _activeCampaign!.prosperityCheckmarks++;
    await databaseHelper.updateCampaign(_activeCampaign!);
    notifyListeners();
  }

  /// Decrements prosperity checkmarks by 1 (minimum 0).
  Future<void> decrementProsperity() async {
    if (_activeCampaign == null || _activeCampaign!.prosperityCheckmarks <= 0) {
      return;
    }
    _activeCampaign!.prosperityCheckmarks--;
    await databaseHelper.updateCampaign(_activeCampaign!);
    notifyListeners();
  }

  // ── Donated Gold ──

  /// Increments donated gold by [amount] (capped at [maxDonatedGold]).
  ///
  /// Returns `true` when the donation just reached [maxDonatedGold],
  /// signalling the UI to show the "open envelope B" snackbar.
  Future<bool> incrementDonatedGold({int amount = 10}) async {
    if (_activeCampaign == null) return false;
    final wasBelow = _activeCampaign!.donatedGold < maxDonatedGold;
    _activeCampaign!.donatedGold = (_activeCampaign!.donatedGold + amount)
        .clamp(0, maxDonatedGold);
    await databaseHelper.updateCampaign(_activeCampaign!);
    notifyListeners();
    return wasBelow && _activeCampaign!.donatedGold >= maxDonatedGold;
  }

  /// Decrements donated gold by [amount] (minimum 0).
  Future<void> decrementDonatedGold({int amount = 10}) async {
    if (_activeCampaign == null || _activeCampaign!.donatedGold <= 0) return;
    _activeCampaign!.donatedGold = (_activeCampaign!.donatedGold - amount)
        .clamp(0, maxDonatedGold);
    await databaseHelper.updateCampaign(_activeCampaign!);
    notifyListeners();
  }

  // ── Party CRUD ──

  /// Creates a new party in the active campaign and sets it as active.
  Future<void> createParty({
    required String name,
    int startingReputation = 0,
  }) async {
    if (_activeCampaign == null) return;

    final party = Party(
      id: const Uuid().v1(),
      campaignId: _activeCampaign!.id,
      name: name,
      reputation: startingReputation,
    );

    await databaseHelper.insertParty(party);
    _parties.add(party);
    _activeParty = party;
    SharedPrefs().activePartyId = party.id;

    notifyListeners();
  }

  /// Sets the active party.
  void setActiveParty(Party party) {
    _activeParty = party;
    SharedPrefs().activePartyId = party.id;
    notifyListeners();
  }

  /// Renames the active party.
  Future<void> renameParty(String newName) async {
    if (_activeParty == null) return;
    _activeParty!.name = newName;
    await databaseHelper.updateParty(_activeParty!);
    notifyListeners();
  }

  /// Deletes the active party and unlinks characters.
  Future<void> deleteActiveParty() async {
    if (_activeParty == null) return;
    await databaseHelper.deleteParty(_activeParty!.id);
    _parties.remove(_activeParty);

    if (_parties.isNotEmpty) {
      _activeParty = _parties.first;
      SharedPrefs().activePartyId = _activeParty!.id;
    } else {
      _activeParty = null;
      SharedPrefs().activePartyId = null;
    }

    notifyListeners();
  }

  // ── Party Details ──

  /// Updates the active party's scenario location.
  Future<void> updatePartyLocation(String location) async {
    if (_activeParty == null) return;
    _activeParty!.location = location;
    await databaseHelper.updateParty(_activeParty!);
    notifyListeners();
  }

  /// Updates the active party's notes.
  Future<void> updatePartyNotes(String notes) async {
    if (_activeParty == null) return;
    _activeParty!.notes = notes;
    await databaseHelper.updateParty(_activeParty!);
    notifyListeners();
  }

  /// Toggles an achievement on/off for the active party.
  Future<void> toggleAchievement(String achievement) async {
    if (_activeParty == null) return;
    if (_activeParty!.achievements.contains(achievement)) {
      _activeParty!.achievements.remove(achievement);
    } else {
      _activeParty!.achievements.add(achievement);
    }
    await databaseHelper.updateParty(_activeParty!);
    notifyListeners();
  }

  // ── Reputation ──

  /// Increments reputation by 1 (max 20).
  Future<void> incrementReputation() async {
    if (_activeParty == null || _activeParty!.reputation >= maxReputation) {
      return;
    }
    _activeParty!.reputation++;
    await databaseHelper.updateParty(_activeParty!);
    notifyListeners();
  }

  /// Decrements reputation by 1 (min -20).
  Future<void> decrementReputation() async {
    if (_activeParty == null || _activeParty!.reputation <= minReputation) {
      return;
    }
    _activeParty!.reputation--;
    await databaseHelper.updateParty(_activeParty!);
    notifyListeners();
  }
}
