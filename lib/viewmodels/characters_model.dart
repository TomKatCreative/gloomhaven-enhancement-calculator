/// Character management and CRUD operations.
///
/// [CharactersModel] is the primary model for character data, handling:
/// - Character CRUD operations (create, read, update, delete)
/// - Character list navigation via PageView
/// - Edit mode state
/// - Perk and mastery selection
/// - Theme synchronization with character colors
/// - Element tracker sheet expansion state
///
/// ## Provider Dependencies
///
/// This model depends on [ThemeProvider] via ProxyProvider for color sync.
/// It also uses [DatabaseHelper] singleton for SQLite persistence.
///
/// ## Character Filtering
///
/// The [characters] getter returns a filtered list based on [showRetired].
/// Internal operations use [_characters] for the full list.
///
/// ## Navigation
///
/// Characters are displayed in a horizontal PageView. The model manages:
/// - [pageController] for page transitions
/// - [currentCharacter] for the selected character
/// - Smart index calculation when toggling retired visibility
///
/// ## Edition-Specific Behavior
///
/// Character creation uses [GameEdition] to determine:
/// - Maximum starting level
/// - Starting gold formula
///
/// See also:
/// - [Character] for the character data model
/// - [ThemeProvider] for theme synchronization
/// - `docs/viewmodels_reference.md` for full documentation
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helpers.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:uuid/uuid.dart';

/// Manages character data, CRUD operations, and list navigation.
///
/// This is the primary model for character management, coordinating between
/// the UI, database, and theme system.
///
/// Key responsibilities:
/// - Load/save characters to SQLite via [databaseHelper]
/// - Track current character and page position
/// - Handle edit mode and perk/mastery selection
/// - Sync theme colors with current character's class
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

  /// Toggles visibility of retired characters and navigates appropriately.
  ///
  /// This is the main entry point for the "show/hide retired" toggle. It handles
  /// several scenarios:
  ///
  /// 1. **Empty list**: Just toggles the setting without navigation.
  /// 2. **Specific character provided**: Navigates to that character (used by
  ///    snackbar "Show" action after retiring a character).
  /// 3. **Currently viewing a retired character while hiding retired**: Finds
  ///    the next non-retired character to navigate to.
  /// 4. **Currently viewing an active character**: Maintains position in the
  ///    filtered list.
  ///
  /// The [character] parameter is optional and used when we want to navigate
  /// to a specific character after toggling (e.g., snackbar "Show" action).
  void toggleShowRetired({Character? character}) {
    if (_characters.isEmpty) {
      _toggleSettingOnly();
      return;
    }

    final int targetIndex = _calculateTargetIndex(character);
    _applyToggleAndNavigate(targetIndex);
  }

  /// Toggles the retired visibility setting without any navigation.
  /// Used when the character list is empty.
  void _toggleSettingOnly() {
    showRetired = !showRetired;
    notifyListeners();
  }

  /// Determines which page index to navigate to after toggling retired visibility.
  ///
  /// Returns the index in the POST-toggle list (i.e., the list that will be
  /// displayed after the toggle is applied).
  ///
  /// Scenarios:
  /// - If [providedCharacter] is given, returns its index in the full list
  ///   (used when navigating to a specific retired character via snackbar).
  /// - If viewing a retired character while about to hide retired, finds the
  ///   next non-retired character.
  /// - If viewing an active character while about to show retired, finds its
  ///   position in the combined list.
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

  /// Determines the target index based on current character's retired status.
  ///
  /// Called when [currentCharacter] is not null. Routes to appropriate handler
  /// based on whether the current character is retired and current visibility.
  int _getIndexForCurrentCharacter() {
    if (currentCharacter!.isRetired) {
      return _findIndexWhenCurrentIsRetired();
    } else if (showRetired) {
      return _findIndexWhenCurrentIsActive();
    } else {
      return _characters.indexOf(currentCharacter!);
    }
  }

  /// Finds the target index when the current character is retired.
  ///
  /// When toggling to hide retired characters while viewing a retired character,
  /// we need to find a non-retired character to display. This method:
  ///
  /// 1. Looks for the first non-retired character AFTER the current position
  ///    in the full list (to maintain a sense of "next" in the original order).
  /// 2. If none found after, falls back to the last non-retired character.
  /// 3. Returns 0 if no non-retired characters exist (empty state).
  ///
  /// Note: Uses [_characters] (unfiltered list) to find the current position
  /// and iterate, since the filtered [characters] list may not contain the
  /// current retired character when [showRetired] is false.
  int _findIndexWhenCurrentIsRetired() {
    // Find position in the FULL list (unfiltered) to iterate from
    final currentIndex = _characters.indexOf(currentCharacter!);

    // Look for next non-retired character after current position
    for (int i = currentIndex + 1; i < _characters.length; i++) {
      if (!_characters[i].isRetired) {
        // Found one - return its position in the non-retired list
        return _getNonRetiredCharacters().indexOf(_characters[i]);
      }
    }

    // No non-retired character found after current position
    // Fall back to the last non-retired character (or 0 if none exist)
    final nonRetiredList = _getNonRetiredCharacters();
    return nonRetiredList.isNotEmpty ? nonRetiredList.length - 1 : 0;
  }

  /// Finds the target index when the current character is active (non-retired).
  ///
  /// When toggling to hide retired characters while viewing an active character,
  /// we need to find where that character will appear in the filtered list.
  /// Simply returns the character's position in the non-retired list.
  int _findIndexWhenCurrentIsActive() {
    return _getNonRetiredCharacters().indexOf(currentCharacter!);
  }

  /// Returns a list of only non-retired characters.
  /// Helper method used by retired character navigation logic.
  List<Character> _getNonRetiredCharacters() {
    return _characters.where((character) => !character.isRetired).toList();
  }

  /// Applies the toggle and navigates to the target index.
  ///
  /// This is the final step after calculating the target index. It:
  /// 1. Flips the [showRetired] flag
  /// 2. Persists the setting to SharedPreferences
  /// 3. Navigates to the target page (if valid)
  /// 4. Notifies listeners to rebuild the UI
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
            edition: GameEdition.values[random.nextInt(3)],
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
          edition: GameEdition.values[random.nextInt(3)],
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
    GameEdition edition = GameEdition.gloomhaven,
    int prosperityLevel = 0,
    Variant variant = Variant.base,
  }) async {
    Character character = Character(
      uuid: const Uuid().v1(),
      name: name,
      playerClass: selectedClass,
      previousRetirements: previousRetirements,
      xp: PlayerClasses.xpByLevel(initialLevel),
      gold: _calculateStartingGold(edition, initialLevel, prosperityLevel),
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

  /// Calculate starting gold based on game edition rules.
  ///
  /// - Gloomhaven: 15 × (L + 1), where L is starting level
  /// - Gloomhaven 2E: 10 × P + 15, where P is prosperity level
  /// - Frosthaven: 10 × P + 20, where P is prosperity level
  int _calculateStartingGold(
    GameEdition edition,
    int startingLevel,
    int prosperityLevel,
  ) {
    switch (edition) {
      case GameEdition.gloomhaven:
        return 15 * (startingLevel + 1);
      case GameEdition.gloomhaven2e:
        return 10 * prosperityLevel + 15;
      case GameEdition.frosthaven:
        return 10 * prosperityLevel + 20;
    }
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

  /// Toggles the retired status of the current character.
  ///
  /// This method handles both retiring and unretiring a character. Key behavior:
  ///
  /// 1. **Captures index BEFORE toggle**: We get the character's index in the
  ///    current (pre-toggle) filtered list. This is important because after
  ///    toggling retired status, the character may no longer be in the filtered
  ///    list (if retired and showRetired=false).
  ///
  /// 2. **Persists to database**: The retired status is saved immediately.
  ///
  /// 3. **Updates current character**: [_setCurrentCharacter] handles the edge
  ///    case where the index becomes invalid (e.g., character disappears from
  ///    filtered list). If the index is out of bounds, it falls back to the
  ///    last character in the list.
  ///
  /// After this method completes, if [showRetired] is false and the character
  /// was just retired, the UI will navigate away from the retired character
  /// (handled by [_setCurrentCharacter]'s bounds checking).
  ///
  /// The caller (AppBar) shows a snackbar with a "Show" action that calls
  /// [toggleShowRetired] with the retired character to navigate back to it.
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
    if (!character.shouldShowMasteries) {
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
