import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';

/// An AppBar with an integrated search field.
///
/// Features:
/// - Platform-aware back button (iOS arrow vs Android arrow)
/// - Integrated SearchBar with clear button
///
/// ## Usage
/// ```dart
/// GHCSearchAppBar(
///   controller: _searchController,
///   focusNode: _searchFocusNode,
///   searchQuery: _searchQuery,
///   onChanged: (value) => setState(() => _searchQuery = value),
///   onClear: () {
///     _searchController.clear();
///     setState(() => _searchQuery = '');
///   },
/// )
/// ```
class GHCSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
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

  const GHCSearchAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
    this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrolledUnderElevation: 0,
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
          controller: controller,
          focusNode: focusNode,
          hintText: hintText ?? AppLocalizations.of(context).search,
          leading: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.search),
          ),
          trailing: searchQuery.isNotEmpty
              ? [IconButton(icon: const Icon(Icons.clear), onPressed: onClear)]
              : null,
          onChanged: onChanged,
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }
}
