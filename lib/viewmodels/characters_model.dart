import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helpers.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:uuid/uuid.dart';

class CharactersModel with ChangeNotifier {
  CharactersModel({
    required this.databaseHelper,
    required this.themeProvider,
    required this.showRetired,
  });

  List<Character> _characters = [];
  Character? currentCharacter;
  DatabaseHelper databaseHelper;
  ThemeProvider themeProvider;
  PageController pageController = PageController(
    initialPage: SharedPrefs().initialPage,
  );
  bool isScrolledToTop = true;
  ScrollController charScreenScrollController = ScrollController();
  ScrollController enhancementCalcScrollController = ScrollController();

  bool showRetired;
  bool _isEditMode = false;
  bool _isElementSheetExpanded = false;
  bool _isElementSheetFullExpanded = false;

  /// Notifier to trigger element sheet collapse from outside the widget.
  /// Increment the value to signal collapse.
  final ValueNotifier<int> collapseElementSheetNotifier = ValueNotifier<int>(0);

  bool get isEditMode => _isEditMode;

  set isEditMode(bool value) {
    _isEditMode = value;
    notifyListeners();
  }

  bool get isElementSheetExpanded => _isElementSheetExpanded;

  set isElementSheetExpanded(bool value) {
    if (_isElementSheetExpanded != value) {
      _isElementSheetExpanded = value;
      notifyListeners();
    }
  }

  bool get isElementSheetFullExpanded => _isElementSheetFullExpanded;

  set isElementSheetFullExpanded(bool value) {
    if (_isElementSheetFullExpanded != value) {
      _isElementSheetFullExpanded = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    charScreenScrollController.dispose();
    enhancementCalcScrollController.dispose();
    super.dispose();
  }

  void toggleShowRetired({Character? character}) {
    if (_characters.isEmpty) {
      _toggleSettingOnly();
      return;
    }

    final int targetIndex = _calculateTargetIndex(character);
    _applyToggleAndNavigate(targetIndex);
  }

  void _toggleSettingOnly() {
    showRetired = !showRetired;
    notifyListeners();
  }

  int _calculateTargetIndex(Character? providedCharacter) {
    // If specific character provided, use it
    if (providedCharacter != null) {
      return _characters.indexOf(providedCharacter);
    }

    // If no current character and retired are hidden, go to first
    if (currentCharacter == null && retiredCharactersAreHidden) {
      return 0;
    }

    // Handle current character scenarios
    if (currentCharacter != null) {
      return _getIndexForCurrentCharacter();
    }

    return 0; // Fallback
  }

  int _getIndexForCurrentCharacter() {
    if (currentCharacter!.isRetired) {
      return _findIndexWhenCurrentIsRetired();
    } else if (showRetired) {
      return _findIndexWhenCurrentIsActive();
    } else {
      return _characters.indexOf(currentCharacter!);
    }
  }

  int _findIndexWhenCurrentIsRetired() {
    // Find next non-retired character after current
    final currentIndex = characters.indexOf(currentCharacter!);

    for (int i = currentIndex + 1; i < characters.length; i++) {
      if (!characters[i].isRetired) {
        // Convert to non-retired list index
        return _getNonRetiredCharacters().indexOf(characters[i]);
      }
    }

    // No non-retired character found after current, go to last non-retired
    final nonRetiredList = _getNonRetiredCharacters();
    return nonRetiredList.isNotEmpty ? nonRetiredList.length - 1 : 0;
  }

  int _findIndexWhenCurrentIsActive() {
    // Current character is active, find its position in non-retired list
    return _getNonRetiredCharacters().indexOf(currentCharacter!);
  }

  List<Character> _getNonRetiredCharacters() {
    return _characters.where((character) => !character.isRetired).toList();
  }

  void _applyToggleAndNavigate(int targetIndex) {
    showRetired = !showRetired;
    SharedPrefs().showRetiredCharacters = showRetired;

    if (targetIndex >= 0) {
      jumpToPage(targetIndex);
      _setCurrentCharacter(index: targetIndex);
    }

    notifyListeners();
  }

  bool get retiredCharactersAreHidden {
    return !showRetired && _characters.isNotEmpty;
  }

  List<Character> get characters => showRetired
      ? _characters
      : _characters.where((character) => !character.isRetired).toList();

  set characters(List<Character> characters) {
    _characters = characters;
    notifyListeners();
  }

  Future<List<Character>> loadCharacters() async {
    List<Character> loadedCharacters = await databaseHelper
        .queryAllCharacters();
    for (Character character in loadedCharacters) {
      character.characterPerks = await _loadPerks(character);
      character.characterMasteries = await _loadMasteries(character);
      characters = loadedCharacters;
    }

    _setCurrentCharacter(index: SharedPrefs().initialPage);
    notifyListeners();
    return characters;
  }

  // Usable for testing purposes to create all characters with all variants and random attributes.
  Future<void> createCharactersTest({
    ClassCategory? classCategory,
    bool includeAllVariants = false,
  }) async {
    var random = Random();

    final playerClassesToCreate = classCategory == null
        ? PlayerClasses.playerClasses
        : PlayerClasses.playerClasses.where(
            (element) => element.category == classCategory,
          );

    for (PlayerClass playerClass in playerClassesToCreate) {
      if (includeAllVariants) {
        // Create a character for each available variant
        final availableVariants = _getAvailableVariants(playerClass);

        for (Variant variant in availableVariants) {
          final variantName = _getVariantDisplayName(playerClass.name, variant);

          await createCharacter(
            variantName,
            playerClass,
            initialLevel: random.nextInt(9) + 1,
            previousRetirements: random.nextInt(4),
            gloomhavenMode: random.nextBool(),
            prosperityLevel: random.nextInt(5),
            variant: variant,
          );
        }
      } else {
        // Create only base variant
        await createCharacter(
          playerClass.name,
          playerClass,
          initialLevel: random.nextInt(9) + 1,
          previousRetirements: random.nextInt(4),
          gloomhavenMode: random.nextBool(),
          prosperityLevel: random.nextInt(5),
        );
      }
    }
  }

  /// Get all available variants for a player class by checking the perks repository
  List<Variant> _getAvailableVariants(PlayerClass playerClass) {
    // Get the perks for this class from the repository
    final perksForClass = PerksRepository.perksMap[playerClass.classCode];

    if (perksForClass == null || perksForClass.isEmpty) {
      return [Variant.base]; // Default to base if no perks found
    }

    // Extract unique variants from the perks list
    return perksForClass.map((perks) => perks.variant).toSet().toList();
  }

  /// Generate a display name for the character based on variant
  String _getVariantDisplayName(String className, Variant variant) {
    switch (variant) {
      case Variant.base:
        return className;
      case Variant.frosthavenCrossover:
        return '$className (FH)';
      case Variant.gloomhaven2E:
        return '$className (GH2E)';
      default:
        return '$className (${variant.name})';
    }
  }

  void onPageChanged(int index) {
    SharedPrefs().initialPage = index;
    isScrolledToTop = true;
    _setCurrentCharacter(index: index);
    _isEditMode = false;
    notifyListeners();
  }

  Future<void> createCharacter(
    String name,
    PlayerClass selectedClass, {
    int initialLevel = 1,
    int previousRetirements = 0,
    bool gloomhavenMode = true,
    int prosperityLevel = 0,
    Variant variant = Variant.base,
  }) async {
    Character character = Character(
      uuid: const Uuid().v1(),
      name: name,
      playerClass: selectedClass,
      previousRetirements: previousRetirements,
      xp: PlayerClasses.xpByLevel(initialLevel),
      gold: gloomhavenMode
          ? 15 * (initialLevel + 1)
          : 10 * prosperityLevel + 20,
      variant: variant,
    );
    character.id = await databaseHelper.insertCharacter(character);
    character.characterPerks = await _loadPerks(character);

    character.characterMasteries = await _loadMasteries(character);

    _characters.add(character);
    if (characters.length > 1) {
      _animateToPage(characters.indexOf(character));
    }
    _setCurrentCharacter(index: characters.indexOf(character));
    notifyListeners();
  }

  Future<void> deleteCurrentCharacter() async {
    _isEditMode = false;
    int index = characters.indexOf(currentCharacter!);
    await databaseHelper.deleteCharacter(currentCharacter!);
    _characters.remove(currentCharacter);
    _setCurrentCharacter(index: index);
    notifyListeners();
  }

  void _setCurrentCharacter({required int index}) {
    if (characters.isEmpty) {
      currentCharacter = null;
      SharedPrefs().initialPage = 0;
    } else {
      if (index < 0 || index >= characters.length) {
        currentCharacter = characters.last;
        SharedPrefs().initialPage = characters.length - 1;
      } else {
        currentCharacter = characters[index];
        SharedPrefs().initialPage = index;
      }
    }
    updateThemeForCharacter(themeProvider);
  }

  void updateThemeForCharacter(ThemeProvider themeProvider) {
    if (characters.isEmpty) {
      themeProvider.updateSeedColor(const Color(0xff4e7ec1));
    } else if (currentCharacter != null) {
      if (currentCharacter!.isRetired) {
        final retiredColor = SharedPrefs().darkTheme
            ? Colors.white
            : Colors.black;
        themeProvider.updateSeedColor(retiredColor);
      } else {
        final characterColor = Color(
          currentCharacter!.playerClass.primaryColor,
        );
        themeProvider.updateSeedColor(characterColor);
      }
    }
  }

  void _animateToPage(int index) {
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void jumpToPage(int index) {
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
      _setCurrentCharacter(index: index);
    }
  }

  Future<void> retireCurrentCharacter() async {
    if (currentCharacter != null) {
      _isEditMode = false;
      int index = characters.indexOf(currentCharacter!);
      currentCharacter!.isRetired = !currentCharacter!.isRetired;
      await databaseHelper.updateCharacter(currentCharacter!);
      _setCurrentCharacter(index: index);
      notifyListeners();
    }
  }

  Future<void> updateCharacter(Character character) async {
    await databaseHelper.updateCharacter(character);
    notifyListeners();
  }

  void increaseCheckmark(Character character) {
    if (character.checkMarks < 18) {
      updateCharacter(character..checkMarks += 1);
    }
  }

  void decreaseCheckmark(Character character) {
    if (character.checkMarks > 0) {
      updateCharacter(character..checkMarks -= 1);
    }
  }

  Future<List<CharacterPerk>> _loadPerks(Character character) async {
    // Load perks from database
    await _loadCharacterPerks(character);

    // Return character-specific perk selections
    return await databaseHelper.queryCharacterPerks(character.uuid);
  }

  Future<void> _loadCharacterPerks(Character character) async {
    final List<Map<String, Object?>> perks = await databaseHelper.queryPerks(
      character,
    );

    for (var perkMap in perks) {
      character.perks.add(Perk.fromMap(perkMap));
    }
  }

  Future<List<CharacterMastery>> _loadMasteries(Character character) async {
    if (!character.showMasteries()) {
      return [];
    }
    List<Map<String, Object?>> masteries = await databaseHelper.queryMasteries(
      character,
    );
    for (var masteryMap in masteries) {
      character.masteries.add(Mastery.fromMap(masteryMap));
    }
    return await databaseHelper.queryCharacterMasteries(character.uuid);
  }

  Future<void> togglePerk({
    required List<CharacterPerk> characterPerks,
    required CharacterPerk perk,
    required bool value,
  }) async {
    for (CharacterPerk characterPerk in characterPerks) {
      if (characterPerk.associatedPerkId == perk.associatedPerkId) {
        characterPerk.characterPerkIsSelected = value;
      }
    }
    await databaseHelper.updateCharacterPerk(perk, value);
    notifyListeners();
  }

  Future<void> toggleMastery({
    required List<CharacterMastery> characterMasteries,
    required CharacterMastery mastery,
    required bool value,
  }) async {
    for (CharacterMastery characterMastery in characterMasteries) {
      if (characterMastery.associatedMasteryId == mastery.associatedMasteryId) {
        characterMastery.characterMasteryAchieved = value;
      }
    }
    await databaseHelper.updateCharacterMastery(mastery, value);
    notifyListeners();
  }
}
