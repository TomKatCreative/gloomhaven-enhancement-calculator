import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/strikethrough_text.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:provider/provider.dart';

/// A searchable bottom sheet for selecting enhancement types.
/// Material 3 compliant with search, grouping by category, and rich item display.
class EnhancementTypeSelector extends StatefulWidget {
  final Enhancement? currentSelection;
  final GameEdition edition;
  final ValueChanged<Enhancement> onSelected;

  const EnhancementTypeSelector({
    super.key,
    this.currentSelection,
    required this.edition,
    required this.onSelected,
  });

  /// Shows the enhancement type selector as a modal bottom sheet.
  static Future<Enhancement?> show(
    BuildContext context, {
    Enhancement? currentSelection,
    required GameEdition edition,
    required ValueChanged<Enhancement> onSelected,
  }) {
    return showModalBottomSheet<Enhancement>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        top: false,
        bottom: true,
        child: EnhancementTypeSelector(
          currentSelection: currentSelection,
          edition: edition,
          onSelected: onSelected,
        ),
      ),
    );
  }

  @override
  State<EnhancementTypeSelector> createState() =>
      _EnhancementTypeSelectorState();
}

class _EnhancementTypeSelectorState extends State<EnhancementTypeSelector> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  List<Enhancement> get _filteredEnhancements {
    final available = EnhancementData.enhancements
        .where((e) => EnhancementData.isAvailableInEdition(e, widget.edition))
        .toList();

    if (_searchQuery.isEmpty) {
      return available;
    }

    final query = _searchQuery.toLowerCase();
    return available
        .where((e) => e.name.toLowerCase().contains(query))
        .toList();
  }

  /// Returns the section title if this item starts a new section, null otherwise
  String? _getSectionHeader(int index) {
    final enhancements = _filteredEnhancements;
    if (index >= enhancements.length) return null;

    final current = enhancements[index];
    final currentSection = current.category.sectionTitle;

    // First item always shows header
    if (index == 0) return currentSection;

    // Show header if section changed from previous item
    final previous = enhancements[index - 1];
    if (previous.category.sectionTitle != currentSection) {
      return currentSection;
    }

    return null;
  }

  /// Returns the asset key for a section header
  String? _getSectionAssetKey(int index) {
    final enhancements = _filteredEnhancements;
    if (index >= enhancements.length) return null;
    return enhancements[index].category.sectionAssetKey;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final model = context.read<EnhancementCalculatorModel>();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header section with background to prevent list items showing through
            Container(
              color: colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: SearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      hintText: AppLocalizations.of(context).search,
                      leading: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.search),
                      ),
                      trailing: _searchQuery.isNotEmpty
                          ? [
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                            ]
                          : null,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerTheme.color,
                  ),
                ],
              ),
            ),
            // Enhancement list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _filteredEnhancements.length,
                itemBuilder: (context, index) {
                  final enhancement = _filteredEnhancements[index];
                  final isSelected = widget.currentSelection == enhancement;
                  final sectionHeader = _getSectionHeader(index);
                  final sectionAssetKey = _getSectionAssetKey(index);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show section header if this item starts a new section
                      if (sectionHeader != null)
                        _buildCategoryHeader(
                          context,
                          sectionHeader,
                          sectionAssetKey,
                        ),
                      // Enhancement item
                      _buildEnhancementTile(
                        context,
                        enhancement,
                        isSelected: isSelected,
                        model: model,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryHeader(
    BuildContext context,
    String title,
    String? assetKey,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.dividerTheme.color)),
          const SizedBox(width: 12),
          if (assetKey != null) ...[
            ThemedSvg(assetKey: assetKey, width: 24, height: 24),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: theme.dividerTheme.color)),
        ],
      ),
    );
  }

  Widget _buildEnhancementTile(
    BuildContext context,
    Enhancement enhancement, {
    required bool isSelected,
    required EnhancementCalculatorModel model,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseCost = enhancement.cost(edition: widget.edition);
    final discountedCost = model.enhancementCost(enhancement);
    final hasDiscount = discountedCost != baseCost;

    return ListTile(
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildEnhancementIcon(enhancement),
      title: Text(enhancement.name, style: theme.textTheme.bodyLarge),
      trailing: _buildCostChip(
        context,
        baseCost: baseCost,
        discountedCost: discountedCost,
        hasDiscount: hasDiscount,
        showMarker: model.hailsDiscount && hasDiscount,
      ),
      onTap: () {
        widget.onSelected(enhancement);
        Navigator.of(context).pop(enhancement);
      },
    );
  }

  Widget _buildEnhancementIcon(Enhancement enhancement) {
    final isPlusOne =
        enhancement.category == EnhancementCategory.charPlusOne ||
        enhancement.category == EnhancementCategory.target ||
        enhancement.category == EnhancementCategory.summonPlusOne;

    if (enhancement.name == 'Element') {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: Stack(
          children: [
            Positioned(
              bottom: 5,
              top: 5,
              left: 5,
              child: SvgPicture.asset(
                'images/elements/elem_dark.svg',
                width: 10,
              ),
            ),
            Positioned(
              top: 4,
              left: 7,
              child: SvgPicture.asset(
                'images/elements/elem_air.svg',
                width: 11,
              ),
            ),
            Positioned(
              top: 3,
              right: 6,
              child: SvgPicture.asset(
                'images/elements/elem_ice.svg',
                width: 12,
              ),
            ),
            Positioned(
              top: 0,
              right: 2,
              bottom: 2,
              child: SvgPicture.asset(
                'images/elements/elem_fire.svg',
                width: 13,
              ),
            ),
            Positioned(
              bottom: 1,
              right: 4,
              child: SvgPicture.asset(
                'images/elements/elem_earth.svg',
                width: 14,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 3,
              child: SvgPicture.asset(
                'images/elements/elem_light.svg',
                width: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ThemedSvg(
      assetKey: enhancement.assetKey!,
      width: iconSize,
      showPlusOneOverlay: isPlusOne,
    );
  }

  Widget _buildCostChip(
    BuildContext context, {
    required int baseCost,
    required int discountedCost,
    required bool hasDiscount,
    required bool showMarker,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: hasDiscount
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StrikethroughText(
                  '${baseCost}g',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${discountedCost}g${showMarker ? ' \u2021' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Text(
              '${baseCost}g',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}
