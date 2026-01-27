import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/info_button_config.dart';

/// Configuration for a single toggle item in a [CalculatorToggleGroupCard].
class ToggleGroupItem {
  /// Optional info button configuration.
  final InfoButtonConfig? infoConfig;

  /// Text title for the toggle. Either [title] or [titleWidget] must be provided.
  final String? title;

  /// Custom widget for the title (e.g., for icon-based titles).
  final Widget? titleWidget;

  /// Optional subtitle displayed below the title.
  final String? subtitle;

  /// Current toggle value.
  final bool value;

  /// Whether the toggle is enabled.
  final bool enabled;

  /// Callback when toggle changes.
  final ValueChanged<bool>? onChanged;

  /// Optional trailing widget (e.g., for Building 44's open_in_new icon).
  final Widget? trailingWidget;

  /// Optional tap handler for the entire row (e.g., for Building 44's dialog).
  final VoidCallback? onTap;

  const ToggleGroupItem({
    this.infoConfig,
    this.title,
    this.titleWidget,
    this.subtitle,
    required this.value,
    this.enabled = true,
    this.onChanged,
    this.trailingWidget,
    this.onTap,
  }) : assert(
         title != null || titleWidget != null,
         'Either title or titleWidget must be provided',
       );
}

/// A card containing multiple toggle items stacked vertically with dividers.
///
/// Used to group related toggles (e.g., modifier options or discount settings).
class CalculatorToggleGroupCard extends StatelessWidget {
  /// The list of toggle items to display.
  final List<ToggleGroupItem> items;

  const CalculatorToggleGroupCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 4 : 1,
      color: isDark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: mediumPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildItemsWithDividers(context),
        ),
      ),
    );
  }

  List<Widget> _buildItemsWithDividers(BuildContext context) {
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      widgets.add(_buildToggleRow(context, items[i]));

      // Add thin divider between items (not after the last one)
      if (i < items.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: largePadding),
            child: Divider(
              height: 1,
              color: Theme.of(context).dividerTheme.color,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildToggleRow(BuildContext context, ToggleGroupItem item) {
    final theme = Theme.of(context);

    void handleToggle() {
      if (item.enabled && item.onChanged != null) {
        item.onChanged!(!item.value);
      }
    }

    void handleTap() {
      if (item.onTap != null) {
        item.onTap!();
      } else {
        handleToggle();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: largePadding, right: smallPadding),
      child: Row(
        children: [
          // Info button
          if (item.infoConfig != null) _buildInfoButton(context, item),
          // Tappable area: title/subtitle
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: handleTap,
              child: Padding(
                padding: EdgeInsets.only(
                  left: item.infoConfig != null ? largePadding : 0,
                  top: mediumPadding,
                  bottom: mediumPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    item.titleWidget ??
                        AutoSizeText(
                          item.title!,
                          maxLines: 2,
                          style: theme.textTheme.bodyLarge,
                        ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Trailing widget (if any) or switch
          if (item.trailingWidget != null) ...[
            GestureDetector(
              onTap: handleTap,
              child: item.trailingWidget,
            ),
            const SizedBox(width: largePadding),
          ] else ...[
            GestureDetector(
              onTap: handleToggle,
              child: Switch(
                value: item.value,
                onChanged: item.enabled ? item.onChanged : null,
              ),
            ),
            const SizedBox(width: mediumPadding),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context, ToggleGroupItem item) {
    return IconButton(
      icon: const Icon(Icons.info_outline_rounded),
      onPressed: item.infoConfig?.enabled == true
          ? () => _showInfoDialog(context, item.infoConfig!)
          : null,
    );
  }

  void _showInfoDialog(BuildContext context, InfoButtonConfig config) {
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
