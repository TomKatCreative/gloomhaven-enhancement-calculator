import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/custom_class_warning_dialog.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_search_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/search_section_header.dart';

/// Result object returned when a player class is selected.
///
/// Contains the selected [PlayerClass] and optionally a [Variant] if the
/// class has multiple editions/versions (e.g., Brute vs Bruiser for GH2E).
class SelectedPlayerClass {
  SelectedPlayerClass({required this.playerClass, this.variant = Variant.base});

  /// The selected player class definition.
  final PlayerClass playerClass;

  /// The variant/edition of the class. Defaults to [Variant.base].
  /// Some classes have different names/perks across editions.
  final Variant? variant;
}

/// A full-page screen for selecting a player class during character creation.
///
/// ## Features
/// - **Search**: Filters classes by name or variant names (e.g., "Bruiser" finds Brute)
/// - **Category filters**: Filter chips to show only specific game editions
/// - **Locked class toggle**: Option to hide unrevealed classes
/// - **Section headers**: Groups classes by [ClassCategory]
/// - **Variant selection**: Shows dialog for classes with multiple versions
///
/// ## Layout
/// ```
/// ┌─────────────────────────────────────┐
/// │ [←]  [🔍 Search...]                 │  ← AppBar with search
/// ├─────────────────────────────────────┤
/// │ [GH] [JotL] [FH] [MP] ...           │  ← Filter chips
/// │ Hide locked classes            [✓]  │  ← Toggle
/// ├─────────────────────────────────────┤
/// │ ──────── Gloomhaven ────────        │  ← Section header
/// │ [Icon] Brute / Bruiser              │
/// │ [Icon] Tinkerer                     │
/// │ ──────── Jaws of the Lion ────────  │
/// │ ...                                 │
/// └─────────────────────────────────────┘
/// ```
///
/// ## Invocation
/// ```dart
/// final result = await ClassSelectorScreen.show(context);
/// if (result != null) {
///   // Use result.playerClass and result.variant
/// }
/// ```
class ClassSelectorScreen extends StatefulWidget {
  const ClassSelectorScreen({super.key});

  /// Shows the class selector screen and returns the selected class.
  ///
  /// Returns [SelectedPlayerClass] if a class was selected, or `null` if
  /// the user navigated back without selecting.
  static Future<SelectedPlayerClass?> show(BuildContext context) {
    return Navigator.push<SelectedPlayerClass>(
      context,
      MaterialPageRoute(builder: (_) => const ClassSelectorScreen()),
    );
  }

  @override
  State<ClassSelectorScreen> createState() => _ClassSelectorScreenState();
}

class _ClassSelectorScreenState extends State<ClassSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  /// Active category filters. Empty means show all categories.
  final Set<ClassCategory> _selectedCategories = {};

  /// Whether to hide locked classes that haven't been revealed.
  bool _hideLockedClasses = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Returns the filtered list of classes based on search query and filters.
  ///
  /// Filtering logic:
  /// 1. Excludes classes disabled in settings (Envelope X, custom classes, etc.)
  /// 2. Optionally excludes locked/unrevealed classes
  /// 3. Filters by search query (matches name or variant names)
  /// 4. Filters by selected categories (if any are selected)
  List<PlayerClass> get _filteredClasses {
    return PlayerClasses.playerClasses.where((playerClass) {
        // Filter out classes that shouldn't be rendered
        if (_doNotRenderPlayerClass(playerClass)) {
          return false;
        }

        // Name/variant must match query
        if (!_matchesClassOrVariantName(playerClass, _searchQuery)) {
          return false;
        }

        // If no category filters are active, include all
        if (_selectedCategories.isEmpty) {
          return true;
        }

        // Include if this class's category is selected
        return _selectedCategories.contains(playerClass.category);
      }).toList()
      // TODO: remove this when reintroducing the Rootwhisperer
      ..removeWhere((element) => element.classCode == 'rw');
  }

  /// Checks if a class should be hidden based on settings and preferences.
  bool _doNotRenderPlayerClass(PlayerClass playerClass) =>
      (!SharedPrefs().envelopeX && playerClass.classCode == 'bs') ||
      (!SharedPrefs().envelopeV && playerClass.classCode == 'vanquisher') ||
      (!SharedPrefs().customClasses &&
          (playerClass.category == ClassCategory.custom ||
              playerClass.category == ClassCategory.crimsonScales)) ||
      (_hideLockedClasses &&
          playerClass.locked &&
          !SharedPrefs().getPlayerClassIsUnlocked(playerClass.classCode));

  /// Checks if class name or any variant name contains the search query.
  bool _matchesClassOrVariantName(PlayerClass playerClass, String query) {
    if (query.isEmpty) return true;
    final queryLower = query.toLowerCase();

    // Check base name
    if (playerClass.name.toLowerCase().contains(queryLower)) {
      return true;
    }

    // Check variant names (e.g., "Bruiser" for Brute in GH2E)
    if (playerClass.variantNames != null) {
      for (final variantName in playerClass.variantNames!.values) {
        if (variantName.toLowerCase().contains(queryLower)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Returns the section header title if this index starts a new category.
  ///
  /// Used to insert [SearchSectionHeader] widgets between category groups.
  String? _getSectionHeader(int index) {
    final classes = _filteredClasses;
    if (index >= classes.length) return null;

    final current = classes[index];
    final currentSection = _getCategoryTitle(current.category);

    // First item always shows header
    if (index == 0) return currentSection;

    // Show header if section changed from previous item
    final previous = classes[index - 1];
    if (_getCategoryTitle(previous.category) != currentSection) {
      return currentSection;
    }

    return null;
  }

  /// Maps [ClassCategory] enum to human-readable section title.
  String _getCategoryTitle(ClassCategory category) {
    return switch (category) {
      ClassCategory.gloomhaven => 'Gloomhaven',
      ClassCategory.jawsOfTheLion => 'Jaws of the Lion',
      ClassCategory.frosthaven => 'Frosthaven',
      ClassCategory.mercenaryPacks => 'Mercenary Packs',
      ClassCategory.crimsonScales => 'Crimson Scales',
      ClassCategory.custom => 'Custom classes',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GHCSearchAppBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        searchQuery: _searchQuery,
        scrollController: _scrollController,
        onChanged: (value) => setState(() => _searchQuery = value),
        onClear: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
        },
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Filter chips and toggle section
            Container(
              color: colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filter chips
                  Padding(
                    padding: const EdgeInsets.only(
                      left: smallPadding,
                      top: smallPadding,
                    ),
                    child: Wrap(
                      runSpacing: smallPadding,
                      spacing: smallPadding,
                      children: [
                        _buildCategoryFilterChip(
                          category: ClassCategory.gloomhaven,
                          label: 'Gloomhaven',
                        ),
                        _buildCategoryFilterChip(
                          category: ClassCategory.jawsOfTheLion,
                          label: 'Jaws of the Lion',
                        ),
                        _buildCategoryFilterChip(
                          category: ClassCategory.frosthaven,
                          label: 'Frosthaven',
                        ),
                        _buildCategoryFilterChip(
                          category: ClassCategory.mercenaryPacks,
                          label: 'Mercenary Packs',
                        ),
                        if (SharedPrefs().customClasses) ...[
                          _buildCategoryFilterChip(
                            category: ClassCategory.crimsonScales,
                            label: 'Crimson Scales',
                          ),
                          _buildCategoryFilterChip(
                            category: ClassCategory.custom,
                            label: 'Custom classes',
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Hide locked classes toggle
                  CheckboxListTile(
                    title: Text(
                      'Hide locked classes',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.right,
                    ),
                    onChanged: (bool? value) => setState(() {
                      _hideLockedClasses = value ?? false;
                    }),
                    value: _hideLockedClasses,
                  ),
                ],
              ),
            ),
            // Class list with section headers
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _filteredClasses.length,
                itemBuilder: (context, index) {
                  final playerClass = _filteredClasses[index];
                  final sectionHeader = _getSectionHeader(index);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sectionHeader != null)
                        SearchSectionHeader(title: sectionHeader),
                      _buildClassTile(playerClass),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a filter chip for a game category.
  Widget _buildCategoryFilterChip({
    required ClassCategory category,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedCategories.contains(category);

    return FilterChip(
      visualDensity: VisualDensity.compact,
      elevation: isSelected ? 4 : 0,
      selected: isSelected,
      onSelected: (value) {
        setState(() {
          if (value) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.remove(category);
          }
        });
      },
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurface,
        ),
      ),
    );
  }

  /// Builds a list tile for a player class.
  ///
  /// Shows:
  /// - Class icon (colored with class primary color)
  /// - Class name (or "???" if locked and unrevealed)
  /// - Visibility toggle button for locked classes
  Widget _buildClassTile(PlayerClass playerClass) {
    final theme = Theme.of(context);
    final bool isUnlocked = SharedPrefs().getPlayerClassIsUnlocked(
      playerClass.classCode,
    );

    Offset? tapPosition;
    return Listener(
      onPointerDown: (event) => tapPosition = event.position,
      child: ListTile(
        leading: ClassIconSvg(
          playerClass: playerClass,
          width: iconSizeXL,
          height: iconSizeXL,
        ),
        title: Text(
          isUnlocked || !playerClass.locked
              ? playerClass.getCombinedDisplayNames()
              : '???',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isUnlocked || !playerClass.locked
                ? null
                : theme.disabledColor,
          ),
        ),
        subtitleTextStyle: theme.textTheme.titleMedium?.copyWith(
          color: theme.disabledColor,
        ),
        subtitle: playerClass.title != null ? Text(playerClass.title!) : null,
        trailing: playerClass.locked
            ? IconButton(
                onPressed: () {
                  setState(() {
                    SharedPrefs().setPlayerClassIsUnlocked(
                      playerClass.classCode,
                      !isUnlocked,
                    );
                  });
                },
                icon: Icon(
                  isUnlocked
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              )
            : null,
        onTap: () async {
          SelectedPlayerClass? choice = await _onClassSelected(
            playerClass,
            tapPosition!,
          );
          if (choice != null && mounted) {
            Navigator.pop<SelectedPlayerClass>(context, choice);
          }
        },
      ),
    );
  }

  /// Handles class selection, showing dialogs as needed.
  ///
  /// For custom classes: Shows a warning dialog about community content.
  /// For multi-variant classes: Shows a popup menu at the tap position.
  Future<SelectedPlayerClass?> _onClassSelected(
    PlayerClass selectedPlayerClass,
    Offset tapPosition,
  ) async {
    bool hideMessage = SharedPrefs().hideCustomClassesWarningMessage;
    bool? proceed = true;
    SelectedPlayerClass userChoice = SelectedPlayerClass(
      playerClass: selectedPlayerClass,
    );

    // Show custom class warning if needed
    if ((selectedPlayerClass.category == ClassCategory.custom) &&
        !hideMessage) {
      proceed = await CustomClassWarningDialog.show(context);
      if (!mounted) return null;
    }

    // Show variant selection if class has multiple versions
    final perkLists = PlayerClass.perkListByClassCode(
      selectedPlayerClass.classCode,
    )!;
    if (perkLists.length > 1) {
      final variant = await showGeneralDialog<Variant>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        barrierColor: Colors.transparent,
        transitionDuration: animationDuration,
        pageBuilder: (context, animation, _) {
          final screen = MediaQuery.of(context).size;
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          final menuContent = ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              elevation: 8,
              borderRadius: BorderRadius.circular(borderRadiusCard),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicWidth(
                child: _VariantMenuContent(perkLists: perkLists),
              ),
            ),
          );
          return CustomSingleChildLayout(
            delegate: _PopupPositionDelegate(
              tapPosition: tapPosition,
              screenSize: screen,
              bottomPadding: bottomPadding,
            ),
            child: menuContent,
          );
        },
      );
      proceed = variant != null;
      userChoice = SelectedPlayerClass(
        playerClass: selectedPlayerClass,
        variant: variant,
      );
    }

    return proceed == true ? userChoice : null;
  }
}

/// Positions the variant popup at the tap point, clamping so it stays
/// fully within the screen viewport and above the system navigation bar.
class _PopupPositionDelegate extends SingleChildLayoutDelegate {
  final Offset tapPosition;
  final Size screenSize;
  final double bottomPadding;

  _PopupPositionDelegate({
    required this.tapPosition,
    required this.screenSize,
    this.bottomPadding = 0,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(screenSize);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = (tapPosition.dx).clamp(
      0.0,
      screenSize.width - childSize.width,
    );
    final top = (tapPosition.dy).clamp(
      0.0,
      screenSize.height - childSize.height - bottomPadding,
    );
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_PopupPositionDelegate oldDelegate) {
    return tapPosition != oldDelegate.tapPosition ||
        screenSize != oldDelegate.screenSize ||
        bottomPadding != oldDelegate.bottomPadding;
  }
}

/// The content of the variant selection popup menu.
class _VariantMenuContent extends StatelessWidget {
  final List<Perks> perkLists;

  const _VariantMenuContent({required this.perkLists});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            extraLargePadding,
            mediumPadding,
            extraLargePadding,
            0,
          ),
          child: Text(
            AppLocalizations.of(context).variant,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...perkLists.map(
          (perkList) => InkWell(
            onTap: () => Navigator.of(context).pop(perkList.variant),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: extraLargePadding,
                vertical: mediumPadding,
              ),
              child: Text(
                ClassVariants.classVariants[perkList.variant]!,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
