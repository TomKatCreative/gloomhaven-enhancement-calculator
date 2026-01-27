import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data/constants.dart';
import 'models/player_class.dart';
import 'shared_prefs.dart';

class CustomSearchDelegate extends SearchDelegate<SelectedPlayerClass> {
  CustomSearchDelegate(List<PlayerClass> playerClass)
    : _playerClasses = playerClass;
  final List<PlayerClass> _playerClasses;

  final Set<ClassCategory> _selectedCategories = {};
  bool hideLockedClasses = false;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  /// Helper method to get the label style for FilterChips
  TextStyle? _getFilterChipLabelStyle(BuildContext context, bool isSelected) {
    if (!isSelected) return null;

    final isDark =
        ThemeData.estimateBrightnessForColor(
          Theme.of(context).colorScheme.primary,
        ) ==
        Brightness.dark;

    return Theme.of(context).textTheme.titleMedium?.copyWith(
      color: isDark ? Colors.white : Colors.black,
    );
  }

  /// Helper method to build a FilterChip with consistent styling
  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      visualDensity: VisualDensity.compact,
      elevation: selected ? 4 : 0,
      labelStyle: _getFilterChipLabelStyle(context, selected),
      selected: selected,
      onSelected: onSelected,
      label: Text(label),
    );
  }

  Widget _buildCategoryFilterChip({
    required BuildContext context,
    required ClassCategory category,
    required String label,
    required StateSetter stateSetter,
  }) {
    final isSelected = _selectedCategories.contains(category);
    return _buildFilterChip(
      context: context,
      label: label,
      selected: isSelected,
      onSelected: (value) {
        stateSetter(() {
          if (value) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.remove(category);
          }
        });
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter stateSetter) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    context: context,
                    category: ClassCategory.gloomhaven,
                    label: 'Gloomhaven',
                    stateSetter: stateSetter,
                  ),
                  _buildCategoryFilterChip(
                    context: context,
                    category: ClassCategory.jawsOfTheLion,
                    label: 'Jaws of the Lion',
                    stateSetter: stateSetter,
                  ),
                  _buildCategoryFilterChip(
                    context: context,
                    category: ClassCategory.frosthaven,
                    label: 'Frosthaven',
                    stateSetter: stateSetter,
                  ),
                  _buildCategoryFilterChip(
                    context: context,
                    category: ClassCategory.mercenaryPacks,
                    label: 'Mercenary Packs',
                    stateSetter: stateSetter,
                  ),
                  if (SharedPrefs().customClasses) ...[
                    _buildCategoryFilterChip(
                      context: context,
                      category: ClassCategory.crimsonScales,
                      label: 'Crimson Scales',
                      stateSetter: stateSetter,
                    ),
                    _buildCategoryFilterChip(
                      context: context,
                      category: ClassCategory.custom,
                      label: 'Custom Classes',
                      stateSetter: stateSetter,
                    ),
                  ],
                ],
              ),
            ),
            CheckboxListTile(
              title: Text(
                'Hide locked classes',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.right,
              ),
              onChanged: (bool? value) => stateSetter(() {
                hideLockedClasses = value ?? false;
              }),
              value: hideLockedClasses,
            ),
            Expanded(
              child: _WordSuggestionList(
                query: query,
                suggestions: _filteredList(_playerClasses),
                onSelected: (String suggestion) {
                  query = suggestion;
                  showResults(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  bool _matchesClassOrVariantName(PlayerClass playerClass, String query) {
    final queryLower = query.toLowerCase();

    // Check base name
    if (playerClass.name.toLowerCase().contains(queryLower)) {
      return true;
    }

    // Check variant names
    if (playerClass.variantNames != null) {
      for (final variantName in playerClass.variantNames!.values) {
        if (variantName.toLowerCase().contains(queryLower)) {
          return true;
        }
      }
    }

    return false;
  }

  List<PlayerClass> _filteredList(List<PlayerClass> playerClasses) {
    return playerClasses.where((playerClass) {
        // Filter out classes that shouldn't be rendered
        if (_doNotRenderPlayerClass(
          playerClass,
          hideLockedClass: hideLockedClasses,
        )) {
          return false;
        }

        // Name/variant must match query
        if (!_matchesClassOrVariantName(playerClass, query)) {
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

  bool _doNotRenderPlayerClass(
    PlayerClass playerClass, {
    required bool hideLockedClass,
  }) =>
      (!SharedPrefs().envelopeX && playerClass.classCode == 'bs') ||
      (!SharedPrefs().envelopeV && playerClass.classCode == 'vanquisher') ||
      (!SharedPrefs().customClasses &&
          (playerClass.category == ClassCategory.custom ||
              playerClass.category == ClassCategory.crimsonScales)) ||
      (hideLockedClass &&
          playerClass.locked &&
          !SharedPrefs().getPlayerClassIsUnlocked(playerClass.classCode));

  @override
  Widget buildResults(BuildContext context) {
    // buildResults is called when showResults(context) is triggered.
    // We display the same filtered list as suggestions since selection
    // is handled via Navigator.pop in the ListTile.onTap callback.
    return _WordSuggestionList(
      query: query,
      suggestions: _filteredList(_playerClasses),
      onSelected: (String suggestion) {
        query = suggestion;
      },
    );
  }
}

class _WordSuggestionList extends StatefulWidget {
  const _WordSuggestionList({
    required this.suggestions,
    required this.query,
    required this.onSelected,
  });

  final List<PlayerClass> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  _WordSuggestionListState createState() => _WordSuggestionListState();
}

class _WordSuggestionListState extends State<_WordSuggestionList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        final PlayerClass selectedPlayerClass = widget.suggestions[index];
        final bool isUnlocked = SharedPrefs().getPlayerClassIsUnlocked(
          selectedPlayerClass.classCode,
        );

        return ListTile(
          leading: SvgPicture.asset(
            'images/class_icons/${selectedPlayerClass.icon}',
            width: iconSize + 5,
            height: iconSize + 5,
            colorFilter: ColorFilter.mode(
              Color(selectedPlayerClass.primaryColor),
              BlendMode.srcIn,
            ),
          ),
          title: Text(
            isUnlocked || !selectedPlayerClass.locked
                ? selectedPlayerClass.getCombinedDisplayNames()
                : '???',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isUnlocked || !selectedPlayerClass.locked
                  ? null
                  : Theme.of(context).disabledColor,
            ),
          ),
          subtitleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).disabledColor,
          ),
          subtitle: selectedPlayerClass.title != null
              ? Text(selectedPlayerClass.title!)
              : null,
          trailing: selectedPlayerClass.locked
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      SharedPrefs().setPlayerClassIsUnlocked(
                        selectedPlayerClass.classCode,
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
              context,
              selectedPlayerClass,
            );
            if (choice != null && context.mounted) {
              Navigator.pop<SelectedPlayerClass>(context, choice);
            }
          },
        );
      },
    );
  }

  /// This method shows a dialog which gives the user the option to select
  /// a specific version of the class, if available.
  Future<SelectedPlayerClass?> _onClassSelected(
    BuildContext context,
    PlayerClass selectedPlayerClass,
  ) async {
    bool hideMessage = SharedPrefs().hideCustomClassesWarningMessage;
    bool? proceed = true;
    SelectedPlayerClass userChoice = SelectedPlayerClass(
      playerClass: selectedPlayerClass,
    );
    if ((selectedPlayerClass.category == ClassCategory.custom) &&
        !hideMessage) {
      proceed = await _showCustomClassWarningDialog(hideMessage);
    }
    // TODO: This can be removed once all classes (Crimson Scales and custom)
    // are converted over to use the Map
    if (PlayerClass.perkListByClassCode(selectedPlayerClass.classCode)!.length >
        1) {
      Variant? variant = await _showVariantDialog(selectedPlayerClass);
      proceed = variant != null;
      userChoice = SelectedPlayerClass(
        playerClass: selectedPlayerClass,
        variant: variant,
      );
      // return userChoice;
    }
    return proceed == true ? userChoice : null;
  }

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
                              style: Theme.of(context).textTheme.bodyMedium
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
                                  } else {
                                    // print(
                                    //     "URL can't be launched.");
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
                                  SharedPrefs()
                                          .hideCustomClassesWarningMessage =
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
          actions:
              PlayerClass.perkListByClassCode(
                  selectedPlayerClass.classCode,
                )!.map((perkList) {
                  return TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(perkList.variant);
                    },
                    child: Text(
                      ClassVariants.classVariants[perkList.variant]!,
                      textAlign: TextAlign.end,
                    ),
                  );
                }).toList()
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

class SelectedPlayerClass {
  SelectedPlayerClass({required this.playerClass, this.variant = Variant.base});
  final PlayerClass playerClass;
  final Variant? variant;
}
