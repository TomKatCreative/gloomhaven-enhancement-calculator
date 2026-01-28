import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/element_stack_icon.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_search_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/search_section_header.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/strikethrough_text.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:provider/provider.dart';

/// A full-page screen for selecting enhancement types in the calculator.
///
/// Displays all available enhancements for the current [GameEdition], grouped
/// by category with search functionality. Each enhancement shows its base cost
/// and any applicable discounts.
///
/// ## Features
/// - **Search**: Filters enhancements by name
/// - **Section headers**: Groups enhancements by [EnhancementCategory]
/// - **Cost display**: Shows base cost and discounted cost (with strikethrough)
/// - **Edition-aware**: Only shows enhancements available in the selected edition
///
/// ## Layout
/// ```
/// ┌─────────────────────────────────────┐
/// │ [←]  [🔍 Search...]                 │  ← AppBar with search
/// ├─────────────────────────────────────┤
/// │ ──────── [+1] +1 Stats ────────     │  ← Section header with icon
/// │ [MOVE] +1 Move                 30g  │
/// │ [ATK]  +1 Attack               50g  │
/// │ ──────── [◇] Elements ────────      │
/// │ [FIRE] Fire                    50g  │
/// │ ...                                 │
/// └─────────────────────────────────────┘
/// ```
///
/// ## Invocation
/// ```dart
/// await EnhancementTypeSelectorScreen.show(
///   context,
///   currentSelection: model.enhancement,
///   edition: model.edition,
///   onSelected: model.enhancementSelected,
/// );
/// ```
class EnhancementTypeSelectorScreen extends StatefulWidget {
  /// The currently selected enhancement, if any. Used for highlight styling.
  final Enhancement? currentSelection;

  /// The game edition to filter available enhancements.
  final GameEdition edition;

  /// Callback invoked when an enhancement is selected.
  final ValueChanged<Enhancement> onSelected;

  const EnhancementTypeSelectorScreen({
    super.key,
    this.currentSelection,
    required this.edition,
    required this.onSelected,
  });

  /// Shows the enhancement type selector as a full page route.
  ///
  /// Returns the selected [Enhancement] or `null` if cancelled.
  static Future<Enhancement?> show(
    BuildContext context, {
    Enhancement? currentSelection,
    required GameEdition edition,
    required ValueChanged<Enhancement> onSelected,
  }) {
    return Navigator.push<Enhancement>(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancementTypeSelectorScreen(
          currentSelection: currentSelection,
          edition: edition,
          onSelected: onSelected,
        ),
      ),
    );
  }

  @override
  State<EnhancementTypeSelectorScreen> createState() =>
      _EnhancementTypeSelectorScreenState();
}

class _EnhancementTypeSelectorScreenState extends State<EnhancementTypeSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  /// Returns enhancements filtered by edition and search query.
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

  /// Returns the section title if this index starts a new category.
  ///
  /// Used to insert [SearchSectionHeader] widgets between category groups.
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

  /// Returns the asset key for a section's icon.
  String? _getSectionAssetKey(int index) {
    final enhancements = _filteredEnhancements;
    if (index >= enhancements.length) return null;
    return enhancements[index].category.sectionAssetKey;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<EnhancementCalculatorModel>();

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
        child: ListView.builder(
          controller: _scrollController,
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
                  SearchSectionHeader(
                    title: sectionHeader,
                    assetKey: sectionAssetKey,
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
    );
  }

  /// Builds a list tile for an enhancement option.
  ///
  /// Shows:
  /// - Enhancement icon (with +1 overlay for stat boosts)
  /// - Enhancement name
  /// - Cost chip (base cost, or strikethrough + discounted if applicable)
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

  /// Builds the icon for an enhancement.
  ///
  /// Special cases:
  /// - "Element" shows a stacked element icon
  /// - +1 stat enhancements show a +1 overlay badge
  Widget _buildEnhancementIcon(Enhancement enhancement) {
    final isPlusOne =
        enhancement.category == EnhancementCategory.charPlusOne ||
        enhancement.category == EnhancementCategory.target ||
        enhancement.category == EnhancementCategory.summonPlusOne;

    if (enhancement.name == 'Element') {
      return ElementStackIcon(size: iconSize);
    }

    return ThemedSvg(
      assetKey: enhancement.assetKey!,
      width: iconSize,
      showPlusOneOverlay: isPlusOne,
    );
  }

  /// Builds the cost display chip for an enhancement.
  ///
  /// If there's a discount (from enhancer level, Hail's discount, etc.),
  /// shows the base cost with strikethrough and the discounted cost.
  /// The ‡ marker indicates Hail's discount is active.
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
