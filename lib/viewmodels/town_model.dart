import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper_interface.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/world.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:uuid/uuid.dart';

/// Manages world and campaign state for the Town screen.
///
/// Handles CRUD operations for worlds and campaigns, and persists
/// the active world/campaign selection in SharedPrefs.
class TownModel with ChangeNotifier {
  TownModel({required this.databaseHelper});

  final IDatabaseHelper databaseHelper;

  List<World> _worlds = [];
  List<Campaign> _campaigns = [];
  World? _activeWorld;
  Campaign? _activeCampaign;
  bool _isEditMode = false;

  // ── Getters ──

  List<World> get worlds => List.unmodifiable(_worlds);
  List<Campaign> get campaigns => List.unmodifiable(_campaigns);
  World? get activeWorld => _activeWorld;
  Campaign? get activeCampaign => _activeCampaign;

  bool get isEditMode => _isEditMode;

  set isEditMode(bool value) {
    _isEditMode = value;
    notifyListeners();
  }

  // ── Loading ──

  /// Loads all worlds from the database and restores active selection.
  Future<void> loadWorlds() async {
    _worlds = await databaseHelper.queryAllWorlds();

    // Restore active world from SharedPrefs
    final savedWorldId = SharedPrefs().activeWorldId;
    if (savedWorldId != null) {
      _activeWorld = _worlds.cast<World?>().firstWhere(
        (w) => w?.id == savedWorldId,
        orElse: () => null,
      );
    }

    // Fall back to first world if saved one not found
    if (_activeWorld == null && _worlds.isNotEmpty) {
      _activeWorld = _worlds.first;
      SharedPrefs().activeWorldId = _activeWorld!.id;
    }

    // Load campaigns for active world
    if (_activeWorld != null) {
      await _loadCampaigns();
    }

    notifyListeners();
  }

  /// Loads campaigns for the active world and restores active campaign.
  Future<void> _loadCampaigns() async {
    if (_activeWorld == null) {
      _campaigns = [];
      _activeCampaign = null;
      return;
    }

    _campaigns = await databaseHelper.queryCampaigns(_activeWorld!.id);

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
  }

  // ── World CRUD ──

  /// Creates a new world and sets it as active.
  Future<void> createWorld({
    required String name,
    required GameEdition edition,
    int startingProsperityCheckmarks = 0,
  }) async {
    final world = World(
      id: const Uuid().v1(),
      name: name,
      edition: edition,
      prosperityCheckmarks: startingProsperityCheckmarks,
    );

    await databaseHelper.insertWorld(world);
    _worlds.add(world);
    _activeWorld = world;
    SharedPrefs().activeWorldId = world.id;

    // Clear campaign state for new world
    _campaigns = [];
    _activeCampaign = null;
    SharedPrefs().activeCampaignId = null;

    _isEditMode = false;
    notifyListeners();
  }

  /// Sets the active world and loads its campaigns.
  Future<void> setActiveWorld(World world) async {
    _activeWorld = world;
    SharedPrefs().activeWorldId = world.id;
    _activeCampaign = null;
    SharedPrefs().activeCampaignId = null;
    await _loadCampaigns();
    _isEditMode = false;
    notifyListeners();
  }

  /// Renames the active world.
  Future<void> renameWorld(String newName) async {
    if (_activeWorld == null) return;
    _activeWorld!.name = newName;
    await databaseHelper.updateWorld(_activeWorld!);
    notifyListeners();
  }

  /// Deletes the active world and all its campaigns.
  Future<void> deleteActiveWorld() async {
    if (_activeWorld == null) return;
    await databaseHelper.deleteWorld(_activeWorld!.id);
    _worlds.remove(_activeWorld);
    _campaigns = [];
    _activeCampaign = null;
    SharedPrefs().activeCampaignId = null;

    if (_worlds.isNotEmpty) {
      _activeWorld = _worlds.first;
      SharedPrefs().activeWorldId = _activeWorld!.id;
      await _loadCampaigns();
    } else {
      _activeWorld = null;
      SharedPrefs().activeWorldId = null;
    }

    _isEditMode = false;
    notifyListeners();
  }

  // ── Prosperity ──

  /// Increments prosperity checkmarks by 1.
  Future<void> incrementProsperity() async {
    if (_activeWorld == null) return;
    _activeWorld!.prosperityCheckmarks++;
    await databaseHelper.updateWorld(_activeWorld!);
    notifyListeners();
  }

  /// Decrements prosperity checkmarks by 1 (minimum 0).
  Future<void> decrementProsperity() async {
    if (_activeWorld == null || _activeWorld!.prosperityCheckmarks <= 0) return;
    _activeWorld!.prosperityCheckmarks--;
    await databaseHelper.updateWorld(_activeWorld!);
    notifyListeners();
  }

  // ── Donated Gold ──

  /// Increments donated gold by 10 (capped at [maxDonatedGold]).
  ///
  /// Returns `true` when the donation just reached [maxDonatedGold],
  /// signalling the UI to show the "open envelope B" snackbar.
  Future<bool> incrementDonatedGold() async {
    if (_activeWorld == null) return false;
    final wasBelow = _activeWorld!.donatedGold < maxDonatedGold;
    _activeWorld!.donatedGold = (_activeWorld!.donatedGold + 10).clamp(
      0,
      maxDonatedGold,
    );
    await databaseHelper.updateWorld(_activeWorld!);
    notifyListeners();
    return wasBelow && _activeWorld!.donatedGold >= maxDonatedGold;
  }

  /// Decrements donated gold by 10 (minimum 0).
  Future<void> decrementDonatedGold() async {
    if (_activeWorld == null || _activeWorld!.donatedGold <= 0) return;
    _activeWorld!.donatedGold = (_activeWorld!.donatedGold - 10).clamp(
      0,
      maxDonatedGold,
    );
    await databaseHelper.updateWorld(_activeWorld!);
    notifyListeners();
  }

  // ── Campaign CRUD ──

  /// Creates a new campaign in the active world and sets it as active.
  Future<void> createCampaign({
    required String name,
    int startingReputation = 0,
  }) async {
    if (_activeWorld == null) return;

    final campaign = Campaign(
      id: const Uuid().v1(),
      worldId: _activeWorld!.id,
      name: name,
      reputation: startingReputation,
    );

    await databaseHelper.insertCampaign(campaign);
    _campaigns.add(campaign);
    _activeCampaign = campaign;
    SharedPrefs().activeCampaignId = campaign.id;

    notifyListeners();
  }

  /// Sets the active campaign.
  void setActiveCampaign(Campaign campaign) {
    _activeCampaign = campaign;
    SharedPrefs().activeCampaignId = campaign.id;
    notifyListeners();
  }

  /// Renames the active campaign.
  Future<void> renameCampaign(String newName) async {
    if (_activeCampaign == null) return;
    _activeCampaign!.name = newName;
    await databaseHelper.updateCampaign(_activeCampaign!);
    notifyListeners();
  }

  /// Deletes the active campaign and unlinks characters.
  Future<void> deleteActiveCampaign() async {
    if (_activeCampaign == null) return;
    await databaseHelper.deleteCampaign(_activeCampaign!.id);
    _campaigns.remove(_activeCampaign);

    if (_campaigns.isNotEmpty) {
      _activeCampaign = _campaigns.first;
      SharedPrefs().activeCampaignId = _activeCampaign!.id;
    } else {
      _activeCampaign = null;
      SharedPrefs().activeCampaignId = null;
    }

    notifyListeners();
  }

  // ── Reputation ──

  /// Increments reputation by 1 (max 20).
  Future<void> incrementReputation() async {
    if (_activeCampaign == null ||
        _activeCampaign!.reputation >= maxReputation) {
      return;
    }
    _activeCampaign!.reputation++;
    await databaseHelper.updateCampaign(_activeCampaign!);
    notifyListeners();
  }

  /// Decrements reputation by 1 (min -20).
  Future<void> decrementReputation() async {
    if (_activeCampaign == null ||
        _activeCampaign!.reputation <= minReputation) {
      return;
    }
    _activeCampaign!.reputation--;
    await databaseHelper.updateCampaign(_activeCampaign!);
    notifyListeners();
  }
}
