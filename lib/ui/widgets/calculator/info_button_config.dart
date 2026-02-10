import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';

/// Configuration for an info button in calculator section cards.
///
/// There are two ways to configure an info button:
/// 1. [InfoButtonConfig.titleMessage] - Provide a title and pre-built message
/// 2. [InfoButtonConfig.category] - Let InfoDialog auto-configure based on enhancement category
class InfoButtonConfig {
  /// Title text for the info dialog (used with [message])
  final String? title;

  /// Pre-built RichText message (used with [title])
  final RichText? message;

  /// Enhancement category for auto-configured dialogs
  final EnhancementCategory? category;

  /// Whether the info button should be disabled
  final bool enabled;

  const InfoButtonConfig._({
    this.title,
    this.message,
    this.category,
    this.enabled = true,
  });

  /// Creates a config with a title and message for the info dialog.
  const InfoButtonConfig.titleMessage({
    required String title,
    required RichText message,
    bool enabled = true,
  }) : this._(title: title, message: message, enabled: enabled);

  /// Creates a config that auto-configures the dialog based on enhancement category.
  const InfoButtonConfig.category({
    required EnhancementCategory category,
    bool enabled = true,
  }) : this._(category: category, enabled: enabled);
}
