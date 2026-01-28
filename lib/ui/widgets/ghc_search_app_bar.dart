import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/app_bar_utils.dart';

/// An AppBar with an integrated search field and scroll-aware tinting.
///
/// Features:
/// - Platform-aware back button (iOS arrow vs Android arrow)
/// - Integrated SearchBar with clear button
/// - Scroll-aware primary color tint (8% overlay) with fade animation
///
/// When a [scrollController] is provided, the AppBar animates its background
/// color based on scroll position:
/// - At top: Uses surface color (no tint)
/// - When scrolled: Fades to 8% primary color tint
///
/// ## Usage
/// ```dart
/// GHCSearchAppBar(
///   controller: _searchController,
///   focusNode: _searchFocusNode,
///   searchQuery: _searchQuery,
///   scrollController: _scrollController,
///   onChanged: (value) => setState(() => _searchQuery = value),
///   onClear: () {
///     _searchController.clear();
///     setState(() => _searchQuery = '');
///   },
/// )
/// ```
class GHCSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// The controller for the search text field.
  final TextEditingController controller;

  /// The focus node for the search text field.
  final FocusNode focusNode;

  /// The current search query value. Used to show/hide clear button.
  final String searchQuery;

  /// Optional hint text override. Defaults to localized "Search".
  final String? hintText;

  /// Callback when search text changes.
  final ValueChanged<String> onChanged;

  /// Callback when clear button is pressed.
  final VoidCallback onClear;

  /// Optional scroll controller to enable scroll-aware tinting.
  ///
  /// When provided, the AppBar animates between surface color (at top)
  /// and tinted color (when scrolled) with a 300ms fade animation.
  final ScrollController? scrollController;

  const GHCSearchAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
    this.hintText,
    required this.onChanged,
    required this.onClear,
    this.scrollController,
  });

  @override
  State<GHCSearchAppBar> createState() => _GHCSearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GHCSearchAppBarState extends State<GHCSearchAppBar> {
  bool _isScrolledToTop = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(GHCSearchAppBar oldWidget) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surface;
    final scrolledColor = AppBarUtils.getTintedBackground(colorScheme);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _isScrolledToTop ? 0.0 : 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, progress, child) {
        return AppBar(
          automaticallyImplyLeading: false,
          elevation: progress * 4.0,
          scrolledUnderElevation: 0,
          backgroundColor: Color.lerp(baseColor, scrolledColor, progress),
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SearchBar(
              controller: widget.controller,
              focusNode: widget.focusNode,
              hintText: widget.hintText ?? AppLocalizations.of(context).search,
              leading: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.search),
              ),
              trailing: widget.searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: widget.onClear,
                      ),
                    ]
                  : null,
              onChanged: widget.onChanged,
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        );
      },
    );
  }
}
