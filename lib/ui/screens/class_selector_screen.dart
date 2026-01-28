import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_search_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/search_section_header.dart';
import 'package:url_launcher/url_launcher.dart';

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
      ClassCategory.custom => 'Custom Classes',
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
                      left: mediumPadding,
                      top: mediumPadding,
                    ),
                    child: Wrap(
                      runSpacing: mediumPadding,
                      spacing: mediumPadding,
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
                            label: 'Custom Classes',
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

    return ListTile(
      leading: SvgPicture.asset(
        'images/class_icons/${playerClass.icon}',
        width: iconSize + 5,
        height: iconSize + 5,
        colorFilter: ColorFilter.mode(
          Color(playerClass.primaryColor),
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        isUnlocked || !playerClass.locked
            ? playerClass.getCombinedDisplayNames()
            : '???',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isUnlocked || !playerClass.locked ? null : theme.disabledColor,
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
        SelectedPlayerClass? choice = await _onClassSelected(playerClass);
        if (choice != null && mounted) {
          Navigator.pop<SelectedPlayerClass>(context, choice);
        }
      },
    );
  }

  /// Handles class selection, showing dialogs as needed.
  ///
  /// For custom classes: Shows a warning dialog about community content.
  /// For multi-variant classes: Shows a variant selection dialog.
  Future<SelectedPlayerClass?> _onClassSelected(
    PlayerClass selectedPlayerClass,
  ) async {
    bool hideMessage = SharedPrefs().hideCustomClassesWarningMessage;
    bool? proceed = true;
    SelectedPlayerClass userChoice = SelectedPlayerClass(
      playerClass: selectedPlayerClass,
    );

    // Show custom class warning if needed
    if ((selectedPlayerClass.category == ClassCategory.custom) && !hideMessage) {
      proceed = await _showCustomClassWarningDialog(hideMessage);
    }

    // Show variant selection if class has multiple versions
    if (PlayerClass.perkListByClassCode(selectedPlayerClass.classCode)!.length >
        1) {
      Variant? variant = await _showVariantDialog(selectedPlayerClass);
      proceed = variant != null;
      userChoice = SelectedPlayerClass(
        playerClass: selectedPlayerClass,
        variant: variant,
      );
    }

    return proceed == true ? userChoice : null;
  }

  /// Shows a warning dialog about custom/community classes.
  Future<bool?> _showCustomClassWarningDialog(bool hideMessage) async {
    return await showDialog<bool?>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Custom Classes',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          content: StatefulBuilder(
            builder: (thisLowerContext, innerSetState) {
              return Container(
                constraints: const BoxConstraints(
                  maxWidth: maxDialogWidth,
                  minWidth: maxDialogWidth,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text:
                                  "Please note that these classes are created by members of the 'Gloomhaven Custom Content Unity Guild' and are subject to change. Use at your own risk and report any incongruencies to the developer. More information can be found on the ",
                            ),
                            TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                              text: 'Discord server',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  Uri uri = Uri(
                                    scheme: 'https',
                                    host: 'discord.gg',
                                    path:
                                        'gloomhaven-custom-content-unity-guild-728375347732807825',
                                  );
                                  var urllaunchable = await canLaunchUrl(uri);
                                  if (urllaunchable) {
                                    await launchUrl(uri);
                                  }
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "Don't show again",
                            overflow: TextOverflow.visible,
                          ),
                          Checkbox(
                            value: hideMessage,
                            onChanged: (bool? value) {
                              if (value != null) {
                                innerSetState(() {
                                  SharedPrefs().hideCustomClassesWarningMessage =
                                      value;
                                  hideMessage = !hideMessage;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Continue'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog to select between class variants/editions.
  Future<Variant?> _showVariantDialog(PlayerClass selectedPlayerClass) async {
    return await showDialog<Variant?>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'images/class_icons/${selectedPlayerClass.icon}',
                width: iconSize + 5,
                height: iconSize + 5,
                colorFilter: ColorFilter.mode(
                  Color(selectedPlayerClass.primaryColor),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: mediumPadding * 2),
              Text(
                selectedPlayerClass.name,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          content: const Text('Version', textAlign: TextAlign.center),
          actions: PlayerClass.perkListByClassCode(
            selectedPlayerClass.classCode,
          )!
              .map((perkList) {
                return TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(perkList.variant);
                  },
                  child: Text(
                    ClassVariants.classVariants[perkList.variant]!,
                    textAlign: TextAlign.end,
                  ),
                );
              })
              .toList()
            ..add(
              TextButton(
                onPressed: (() => Navigator.of(context).pop()),
                child: const Text('Cancel'),
              ),
            ),
        );
      },
    );
  }
}
