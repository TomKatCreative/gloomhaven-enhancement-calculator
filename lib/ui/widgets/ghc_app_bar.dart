import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/app_bar_utils.dart';

/// Standard AppBar for pushed routes with scroll-aware tinting.
///
/// Features:
/// - Platform-aware back button (iOS arrow vs Android arrow)
/// - Scroll-aware primary color tint (8% overlay) with fade animation
/// - Optional subtitle below title
/// - Optional action buttons
///
/// When a [scrollController] is provided, the AppBar animates its background
/// color based on scroll position:
/// - At top: Uses surface color (no tint)
/// - When scrolled: Fades to 8% primary color tint
///
/// For the Home screen's scroll-animated AppBar, use [GHCAnimatedAppBar].
/// For search-enabled AppBars, use [GHCSearchAppBar].
///
/// ## Usage
/// ```dart
/// GHCAppBar(
///   title: 'Settings',
///   scrollController: _scrollController,
///   actions: [
///     IconButton(icon: Icon(Icons.save), onPressed: _save),
///   ],
/// )
/// ```
class GHCAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// The primary title text displayed in the AppBar.
  /// If null, no title is displayed.
  final String? title;

  /// Optional widget displayed below the title.
  final Widget? subtitle;

  /// Whether to center the title. Defaults to false.
  final bool centerTitle;

  /// Optional action buttons displayed on the right side.
  final List<Widget>? actions;

  /// Custom text style for the title. If null, uses headlineLarge from theme.
  final TextStyle? titleStyle;

  /// Optional scroll controller to enable scroll-aware tinting.
  ///
  /// When provided, the AppBar animates between surface color (at top)
  /// and tinted color (when scrolled) with a 300ms fade animation.
  final ScrollController? scrollController;

  const GHCAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.centerTitle = false,
    this.actions,
    this.titleStyle,
    this.scrollController,
  });

  @override
  State<GHCAppBar> createState() => _GHCAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GHCAppBarState extends State<GHCAppBar> {
  bool _isScrolledToTop = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(GHCAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_scrollListener);
      widget.scrollController?.addListener(_scrollListener);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;

    final isAtTop = controller.offset <= controller.position.minScrollExtent;

    if (isAtTop != _isScrolledToTop) {
      setState(() => _isScrolledToTop = isAtTop);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseColor = colorScheme.surface;
    final scrolledColor = AppBarUtils.getTintedBackground(colorScheme);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _isScrolledToTop ? 0.0 : 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, progress, child) {
        return AppBar(
          automaticallyImplyLeading: false,
          centerTitle: widget.centerTitle,
          elevation: progress * 4.0,
          scrolledUnderElevation: 0,
          backgroundColor: Color.lerp(baseColor, scrolledColor, progress),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
            ),
          ),
          title: widget.title != null
              ? (widget.subtitle != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title!,
                            style:
                                widget.titleStyle ??
                                theme.textTheme.headlineLarge,
                          ),
                          widget.subtitle!,
                        ],
                      )
                    : Text(
                        widget.title!,
                        style:
                            widget.titleStyle ?? theme.textTheme.headlineLarge,
                      ))
              : null,
          actions: widget.actions,
        );
      },
    );
  }
}
