import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/element_state.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/animated_element_icon.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

/// A draggable bottom sheet for tracking element states.
///
/// Displays 6 game elements (FIRE, ICE, AIR, EARTH, LIGHT, DARK) that can be
/// tapped to cycle through states: gone -> strong -> waning -> gone.
///
/// Icons smoothly animate size and spacing as the sheet is dragged.
class ElementTrackerSheet extends StatefulWidget {
  const ElementTrackerSheet({super.key});

  @override
  State<ElementTrackerSheet> createState() => _ElementTrackerSheetState();
}

class _ElementTrackerSheetState extends State<ElementTrackerSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  // Sheet size configuration (three states)
  static const double _collapsedSize = 0.065;
  static const double _expandedSize = 0.14;
  static const double _fullExpandedSize = 0.85;

  // Thresholds for determining current state
  static const double _expansionThreshold = 0.10;
  static const double _fullExpansionThreshold = 0.50;

  // Icon sizes for each state (uses standard sizes where applicable)
  // Note: _fullExpandedIconSize is unique to this widget and kept as local constant
  static const double _fullExpandedIconSize = 100.0;

  // Padding values
  static const double _collapsedIconPadding = 3.0;
  static const double _expandedIconPadding = 8.0;
  static const double _collapsedVerticalPadding = 2.0;
  static const double _expandedVerticalPadding = 8.0;
  static const double _fullExpandedVerticalPadding = 16.0;

  // Element asset keys in display order
  static const List<String> _elementKeys = [
    'FIRE',
    'ICE',
    'AIR',
    'EARTH',
    'LIGHT',
    'DARK',
  ];

  // Map element keys to SharedPrefs getters/setters
  late final Map<String, int Function()> _stateGetters;
  late final Map<String, void Function(int)> _stateSetters;

  ValueNotifier<int>? _collapseNotifier;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSheetPositionChanged);
    _initStateAccessors();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for collapse signals from navigation (only subscribe once)
    final notifier = context
        .read<CharactersModel>()
        .collapseElementSheetNotifier;
    if (_collapseNotifier != notifier) {
      _collapseNotifier?.removeListener(_onCollapseSignal);
      _collapseNotifier = notifier;
      _collapseNotifier!.addListener(_onCollapseSignal);
    }
  }

  void _onCollapseSignal() {
    if (_controller.isAttached && _controller.size > _collapsedSize) {
      _controller.jumpTo(_collapsedSize);
    }
  }

  void _initStateAccessors() {
    final prefs = SharedPrefs();
    _stateGetters = {
      'FIRE': () => prefs.fireState,
      'ICE': () => prefs.iceState,
      'AIR': () => prefs.airState,
      'EARTH': () => prefs.earthState,
      'LIGHT': () => prefs.lightState,
      'DARK': () => prefs.darkState,
    };
    _stateSetters = {
      'FIRE': (v) => prefs.fireState = v,
      'ICE': (v) => prefs.iceState = v,
      'AIR': (v) => prefs.airState = v,
      'EARTH': (v) => prefs.earthState = v,
      'LIGHT': (v) => prefs.lightState = v,
      'DARK': (v) => prefs.darkState = v,
    };
  }

  @override
  void dispose() {
    _collapseNotifier?.removeListener(_onCollapseSignal);
    _controller.removeListener(_onSheetPositionChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Calculates expansion progress from 0.0 (collapsed) to 1.0 (expanded)
  /// This is for the first expansion stage (collapsed -> expanded row)
  double get _expansionProgress {
    if (!_controller.isAttached) return 0.0;
    final size = _controller.size;
    final progress = (size - _collapsedSize) / (_expandedSize - _collapsedSize);
    return progress.clamp(0.0, 1.0);
  }

  /// Calculates full expansion progress from 0.0 (expanded) to 1.0 (full)
  /// This is for the second expansion stage (expanded row -> full grid)
  double get _fullExpansionProgress {
    if (!_controller.isAttached) return 0.0;
    final size = _controller.size;
    if (size <= _expandedSize) return 0.0;
    final progress =
        (size - _expandedSize) / (_fullExpandedSize - _expandedSize);
    return progress.clamp(0.0, 1.0);
  }

  bool get _isExpanded =>
      _controller.isAttached && _controller.size > _expansionThreshold;
  bool get _isFullExpanded =>
      _controller.isAttached && _controller.size > _fullExpansionThreshold;

  void _onSheetPositionChanged() {
    // Trigger rebuild to update interpolated values
    setState(() {});
    // Update model for FAB visibility and padding calculations
    final model = context.read<CharactersModel>();
    model.isElementSheetExpanded = _isExpanded;
    model.isElementSheetFullExpanded = _isFullExpanded;
  }

  void _toggleExpanded() {
    // Cycle through: collapsed -> expanded -> collapsed
    // (Tapping handle doesn't go to full - user drags for that)
    final targetSize = _isExpanded ? _collapsedSize : _expandedSize;
    _controller.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  ElementState _getElementState(String key) {
    final getter = _stateGetters[key];
    if (getter == null) return ElementState.gone;
    return ElementState.fromIndex(getter());
  }

  void _cycleElementState(String key) {
    final currentState = _getElementState(key);
    final nextState = currentState.nextState();
    final setter = _stateSetters[key];
    if (setter != null) {
      setter(nextState.index);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetColor =
        theme.bottomNavigationBarTheme.backgroundColor ??
        theme.colorScheme.surface;

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _collapsedSize,
      minChildSize: _collapsedSize,
      maxChildSize: _fullExpandedSize,
      snap: true,
      snapSizes: const [_collapsedSize, _expandedSize, _fullExpandedSize],
      builder: (context, scrollController) {
        final progress = _expansionProgress;
        final fullProgress = _fullExpansionProgress;

        // Interpolate padding values (two-stage interpolation)
        // Stage 1: collapsed -> expanded
        final topPadding1 = lerpDouble(6, 8, progress)!;
        // Space below handle when expanded (fixed, no interpolation)
        const handleBottomPadding1 = 4.0;
        final verticalPadding1 = lerpDouble(
          _collapsedVerticalPadding,
          _expandedVerticalPadding,
          progress,
        )!;
        final bottomPadding1 = lerpDouble(4, 8, progress)!;

        // Stage 2: expanded -> full expanded
        final topPadding = lerpDouble(topPadding1, 16, fullProgress)!;
        final handleBottomPadding = lerpDouble(
          handleBottomPadding1,
          16,
          fullProgress,
        )!;
        final verticalPadding = lerpDouble(
          verticalPadding1,
          _fullExpandedVerticalPadding,
          fullProgress,
        )!;
        final bottomPadding = lerpDouble(bottomPadding1, 24, fullProgress)!;

        return Container(
          decoration: BoxDecoration(
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle (tappable to toggle)
                GestureDetector(
                  onTap: _toggleExpanded,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      SizedBox(height: topPadding),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: handleBottomPadding),
                    ],
                  ),
                ),
                // Element icons (row or grid depending on expansion)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: verticalPadding,
                  ),
                  child: _buildElementLayout(progress, fullProgress),
                ),
                SizedBox(height: bottomPadding),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildElementLayout(double progress, double fullProgress) {
    // Two-stage icon size interpolation
    final iconSize1 = lerpDouble(iconSizeSmall, iconSizeXL, progress)!;
    final iconSize = lerpDouble(
      iconSize1,
      _fullExpandedIconSize,
      fullProgress,
    )!;

    // AnimatedElementIcon adds ring padding (2px each side = 4px total)
    const double ringPaddingTotal = 4.0;
    final totalIconSize = iconSize + ringPaddingTotal;

    // Build icon widgets
    List<Widget> buildIcons() {
      return _elementKeys.map((key) {
        final state = _getElementState(key);
        final icon = AnimatedElementIcon(
          assetKey: key,
          state: state,
          size: iconSize,
          animated: _isExpanded,
        );

        // Only interactive when past threshold
        if (_isExpanded) {
          return GestureDetector(
            onTap: () => _cycleElementState(key),
            child: icon,
          );
        }
        return icon;
      }).toList();
    }

    final icons = buildIcons();

    // Use LayoutBuilder to get available width for position calculations
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Calculate row positions (expanded state)
        final rowPositions = _calculateRowPositions(
          availableWidth,
          totalIconSize,
          progress,
        );

        // Calculate grid positions (full expanded state)
        final gridPositions = _calculateGridPositions(
          availableWidth,
          totalIconSize,
          fullProgress,
        );

        // Interpolate between row and grid positions
        final positions = <Offset>[];
        for (int i = 0; i < 6; i++) {
          final x = lerpDouble(
            rowPositions[i].dx,
            gridPositions[i].dx,
            fullProgress,
          )!;
          final y = lerpDouble(
            rowPositions[i].dy,
            gridPositions[i].dy,
            fullProgress,
          )!;
          positions.add(Offset(x, y));
        }

        // Calculate total height needed
        final maxY = positions.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
        final totalHeight = maxY + totalIconSize;

        return SizedBox(
          width: availableWidth,
          height: totalHeight,
          child: Stack(
            children: [
              for (int i = 0; i < icons.length; i++)
                Positioned(
                  left: positions[i].dx,
                  top: positions[i].dy,
                  child: icons[i],
                ),
            ],
          ),
        );
      },
    );
  }

  /// Calculate icon positions for row layout
  List<Offset> _calculateRowPositions(
    double availableWidth,
    double iconSize,
    double progress,
  ) {
    // Reserve space for FAB on the right when expanded (FAB is ~56px + 16px margin)
    const fabReservedSpace = 72.0;
    final rightPadding = fabReservedSpace * progress;
    final effectiveWidth = availableWidth - rightPadding;

    final iconPadding1 = lerpDouble(
      _collapsedIconPadding,
      _expandedIconPadding,
      progress,
    )!;
    final paddedIconWidth = iconSize + (iconPadding1 * 2);
    final totalIconsWidth = 6 * paddedIconWidth;

    final extraSpace = (effectiveWidth - totalIconsWidth).clamp(
      0.0,
      double.infinity,
    );
    final distributedSpace = extraSpace * progress;
    final spaceBetween = distributedSpace / 5; // 5 gaps between 6 icons

    final positions = <Offset>[];
    // Center within the effective width (left-shifted to avoid FAB)
    final startX = (effectiveWidth - totalIconsWidth - distributedSpace) / 2;

    for (int i = 0; i < 6; i++) {
      final x = startX + iconPadding1 + (i * (paddedIconWidth + spaceBetween));
      positions.add(Offset(x, 0));
    }

    return positions;
  }

  /// Calculate icon positions for grid layout (2 columns, 3 rows)
  /// Spacing is responsive to available width for different screen sizes
  List<Offset> _calculateGridPositions(
    double availableWidth,
    double iconSize,
    double fullProgress,
  ) {
    // Calculate responsive spacing based on available width
    // Remaining horizontal space after placing 2 icons
    final remainingHorizontal = availableWidth - (iconSize * 2);

    // Use ~45% of remaining space for center gap (rest becomes side margins)
    // Clamp to reasonable bounds: min 24px (small phones), max 80px (tablets)
    final targetSpacing = (remainingHorizontal * 0.45).clamp(24.0, 80.0);

    // Interpolate from compact spacing (8px) to responsive target
    final gridSpacing = lerpDouble(8, targetSpacing, fullProgress)!;
    final rowSpacing = gridSpacing; // Same vertical spacing for visual balance

    // Two columns centered
    final totalGridWidth = (iconSize * 2) + gridSpacing;
    final startX = (availableWidth - totalGridWidth) / 2;

    // Column positions
    final col0X = startX;
    final col1X = startX + iconSize + gridSpacing;

    // Row positions
    final row0Y = 0.0;
    final row1Y = iconSize + rowSpacing;
    final row2Y = (iconSize + rowSpacing) * 2;

    // Grid order: FIRE ICE / AIR EARTH / LIGHT DARK
    return [
      Offset(col0X, row0Y), // FIRE
      Offset(col1X, row0Y), // ICE
      Offset(col0X, row1Y), // AIR
      Offset(col1X, row1Y), // EARTH
      Offset(col0X, row2Y), // LIGHT
      Offset(col1X, row2Y), // DARK
    ];
  }
}
