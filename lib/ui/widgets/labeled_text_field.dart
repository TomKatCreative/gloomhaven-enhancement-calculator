import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// A text field with an external label and optional icon.
///
/// Used for form fields in screens like character creation where
/// the label should appear above the text field with an icon.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    this.icon,
    this.svgAssetKey,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.validator,
    this.suffixIcon,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.enableInteractiveSelection = true,
    this.autocorrect = true,
  }) : assert(
         icon != null || svgAssetKey != null,
         'Either icon or svgAssetKey must be provided',
       );

  /// The label text displayed above the text field.
  final String label;

  /// Material icon to display before the label.
  final IconData? icon;

  /// SVG asset key to display before the label (alternative to [icon]).
  final String? svgAssetKey;

  /// Hint text displayed inside the text field when empty.
  final String? hintText;

  /// Controller for the text field.
  final TextEditingController? controller;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// Optional input formatters for the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Called when the text field value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the text field is tapped.
  final VoidCallback? onTap;

  /// Whether the text field is read-only.
  final bool readOnly;

  /// Whether the text field is enabled.
  final bool enabled;

  /// Validator function for form validation.
  final FormFieldValidator<String>? validator;

  /// Widget to display at the end of the text field.
  final Widget? suffixIcon;

  /// Whether to autofocus the text field.
  final bool autofocus;

  /// Focus node for the text field.
  final FocusNode? focusNode;

  /// How to capitalize text input.
  final TextCapitalization textCapitalization;

  /// Whether to enable interactive selection (copy/paste).
  final bool enableInteractiveSelection;

  /// Whether to enable autocorrect.
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: label, icon: icon, svgAssetKey: svgAssetKey),
        const SizedBox(height: mediumPadding),
        TextFormField(
          controller: controller,
          autofocus: autofocus,
          focusNode: focusNode,
          readOnly: readOnly,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onTap: onTap,
          validator: validator,
          textCapitalization: textCapitalization,
          enableInteractiveSelection: enableInteractiveSelection,
          autocorrect: autocorrect,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// A label row with an icon, used for section headers.
///
/// Can be used standalone for non-text-field sections (sliders, toggles)
/// or as part of [LabeledTextField].
class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.label,
    this.icon,
    this.svgAssetKey,
    this.textStyle,
  }) : assert(
         icon != null || svgAssetKey != null,
         'Either icon or svgAssetKey must be provided',
       );

  /// The label text to display.
  final String label;

  /// Material icon to display before the label.
  final IconData? icon;

  /// SVG asset key to display before the label (alternative to [icon]).
  final String? svgAssetKey;

  /// Custom text style for the label. If null, uses labelLarge.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        if (icon != null)
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        if (svgAssetKey != null)
          ThemedSvg(
            assetKey: svgAssetKey!,
            width: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        const SizedBox(width: mediumPadding),
        Text(label, style: textStyle ?? defaultStyle),
      ],
    );
  }
}
