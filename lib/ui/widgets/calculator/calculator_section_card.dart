import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/cost_display.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/info_button_config.dart';

/// Layout variants for [CalculatorSectionCard].
enum CardLayoutVariant {
  /// Standard layout with title header, body widget, and optional cost display.
  /// Used for sliders, segmented buttons, dropdowns.
  standard,

  /// Toggle layout with info button, title, and switch on the same row.
  /// Used for boolean options.
  toggle,
}

/// A standardized card component for enhancement calculator sections.
///
/// Provides consistent layout, spacing, and styling across all calculator cards.
/// Supports two layout variants:
///
/// **Standard layout** (`CardLayoutVariant.standard`):
/// ```
/// +--------------------------------------------------+
/// | [i] Title                                        |
/// |                                                  |
/// | [Body Widget - full width]                       |
/// |                                                  |
/// | [Cost Display Chip]                              |
/// +--------------------------------------------------+
/// ```
///
/// **Toggle layout** (`CardLayoutVariant.toggle`):
/// ```
/// +--------------------------------------------------+
/// | [i]  Title                              [Toggle] |
/// |      Subtitle (optional)                         |
/// +--------------------------------------------------+
/// ```
class CalculatorSectionCard extends StatelessWidget {
  /// Optional info button configuration. If null, no info button is shown.
  final InfoButtonConfig? infoConfig;

  /// The section title displayed in the header. Required unless [titleWidget] is provided.
  final String? title;

  /// Optional widget to display instead of [title]. Useful for icon-based titles.
  final Widget? titleWidget;

  /// Optional subtitle displayed below the title (toggle layout only).
  final String? subtitle;

  /// The main content widget (slider, segmented button, dropdown, etc.).
  /// For toggle layout, this should be null - use [toggleValue] and [onToggleChanged] instead.
  final Widget? body;

  /// Optional cost display shown below the body (standard layout only).
  final CostDisplayConfig? costConfig;

  /// The layout variant to use.
  final CardLayoutVariant layout;

  /// Current toggle value (toggle layout only).
  final bool? toggleValue;

  /// Callback when toggle changes (toggle layout only).
  final ValueChanged<bool>? onToggleChanged;

  /// Whether the toggle is enabled (toggle layout only).
  final bool toggleEnabled;

  const CalculatorSectionCard({
    super.key,
    this.infoConfig,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.body,
    this.costConfig,
    this.layout = CardLayoutVariant.standard,
    this.toggleValue,
    this.onToggleChanged,
    this.toggleEnabled = true,
  }) : assert(
         title != null || titleWidget != null,
         'Either title or titleWidget must be provided',
       ),
       assert(
         layout == CardLayoutVariant.standard || toggleValue != null,
         'Toggle layout requires toggleValue',
       );

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: mediumPadding),
        child: layout == CardLayoutVariant.toggle
            ? _buildToggleLayout(context)
            : _buildStandardLayout(context),
      ),
    );
  }

  Widget _buildStandardLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with info button and title
          _buildHeader(context),
          // Body content
          if (body != null) body!,
          // Cost display
          if (costConfig != null) ...[
            const SizedBox(height: mediumPadding),
            CostDisplay(config: costConfig!),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    void handleTap() {
      if (toggleEnabled && onToggleChanged != null) {
        onToggleChanged!(!toggleValue!);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: largePadding, right: smallPadding),
      child: Row(
        children: [
          // Info button (not tappable for toggle)
          if (infoConfig != null) _buildInfoButton(context),
          // Tappable area: title/subtitle and switch
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: handleTap,
              child: Padding(
                padding: EdgeInsets.only(
                  left: infoConfig != null ? largePadding : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    titleWidget ??
                        AutoSizeText(
                          title!,
                          maxLines: 2,
                          style: theme.textTheme.bodyLarge,
                        ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Switch (also tappable via GestureDetector wrapping it)
          GestureDetector(
            onTap: handleTap,
            child: Switch(
              value: toggleValue!,
              onChanged: toggleEnabled ? onToggleChanged : null,
            ),
          ),
          const SizedBox(width: mediumPadding),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (infoConfig != null) ...[
          _buildInfoButton(context),
          const SizedBox(width: largePadding),
        ],
        Expanded(
          child: titleWidget ?? Text(title!, style: theme.textTheme.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline_rounded),
      onPressed: infoConfig?.enabled == true
          ? () => _showInfoDialog(context)
          : null,
    );
  }

  void _showInfoDialog(BuildContext context) {
    final config = infoConfig!;

    showDialog<void>(
      context: context,
      builder: (_) {
        if (config.category != null) {
          return InfoDialog(category: config.category);
        }
        return InfoDialog(title: config.title, message: config.message);
      },
    );
  }
}
