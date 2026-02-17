import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/envelope_puzzle_dialog.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:provider/provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/settings/settings_section_header.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// Settings section for gameplay-related preferences.
///
/// Contains:
/// - Envelope X puzzle toggle (Gloomhaven spoilers)
/// - Envelope V puzzle toggle (Crimson Scales spoilers)
/// - Enhancement guidelines link
class GameplaySettingsSection extends StatelessWidget {
  const GameplaySettingsSection({super.key, required this.onSettingsChanged});

  /// Callback triggered when any setting in this section changes.
  final VoidCallback onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsSectionHeader(title: l10n.gameplay),
        _buildEnvelopeXToggle(context, theme, l10n),
        _buildEnvelopeVToggle(context, theme, l10n),
        _buildEnhancementGuidelinesLink(context, theme, l10n),
      ],
    );
  }

  Widget _buildEnvelopeXToggle(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return SwitchListTile(
      secondary: Icon(
        SharedPrefs().envelopeX ? Icons.drafts_rounded : Icons.mail_rounded,
      ),
      title: Text(l10n.solveEnvelopeX),
      subtitle: Text(l10n.gloomhavenSpoilers),
      value: SharedPrefs().envelopeX,
      onChanged: (val) => _handleEnvelopeXToggle(context, l10n, val),
    );
  }

  Future<void> _handleEnvelopeXToggle(
    BuildContext context,
    AppLocalizations l10n,
    bool val,
  ) async {
    if (!val) {
      SharedPrefs().envelopeX = false;
      onSettingsChanged();
      return;
    }

    final solved = await EnvelopePuzzleDialog.show(
      context: context,
      promptText: l10n.enterSolution,
      inputLabel: l10n.solution,
      correctAnswer: 'bladeswarm',
      successButtonText: l10n.solve,
    );

    if (solved == true) {
      SharedPrefs().envelopeX = true;
      onSettingsChanged();
      if (!context.mounted) return;
      _showEnvelopeXSuccessSnackBar(context, l10n);
    }
  }

  void _showEnvelopeXSuccessSnackBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ThemedSvg(
                assetKey: 'Bladeswarm',
                width: iconSizeLarge,
                height: iconSizeLarge,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              const SizedBox(width: smallPadding),
              Text(l10n.bladeswarmUnlocked),
            ],
          ),
        ),
      );
  }

  Widget _buildEnvelopeVToggle(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return SwitchListTile(
      secondary: Icon(
        SharedPrefs().envelopeV ? Icons.drafts_rounded : Icons.mail_rounded,
      ),
      title: Text(l10n.unlockEnvelopeV),
      subtitle: Text(l10n.crimsonScalesSpoilers),
      value: SharedPrefs().envelopeV,
      onChanged: (val) => _handleEnvelopeVToggle(context, l10n, val),
    );
  }

  Future<void> _handleEnvelopeVToggle(
    BuildContext context,
    AppLocalizations l10n,
    bool val,
  ) async {
    if (!val) {
      SharedPrefs().envelopeV = false;
      onSettingsChanged();
      return;
    }

    final solved = await EnvelopePuzzleDialog.show(
      context: context,
      promptText: l10n.enterPassword,
      inputLabel: l10n.password,
      correctAnswer: 'ashes',
      successButtonText: l10n.unlock,
    );

    if (solved == true) {
      SharedPrefs().envelopeV = true;
      onSettingsChanged();
      if (!context.mounted) return;
      _showEnvelopeVSuccessSnackBar(context, l10n);
    }
  }

  void _showEnvelopeVSuccessSnackBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ThemedSvg(
                assetKey: 'RAGE',
                width: iconSizeLarge,
                height: iconSizeLarge,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              const SizedBox(width: smallPadding),
              Text(l10n.vanquisherUnlocked),
            ],
          ),
        ),
      );
  }

  Widget _buildEnhancementGuidelinesLink(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: const ThemedSvg(assetKey: 'ENHANCEMENTS'),
      title: Text(l10n.enhancementGuidelines),
      trailing: SizedBox(
        width: 60, // Match Switch width for alignment
        child: Center(
          child: Icon(
            Icons.open_in_new,
            size: iconSizeMedium,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) {
          return InfoDialog(
            title: Strings.generalInfoTitle,
            message: Strings.generalInfoBody(
              context,
              edition: context.read<EnhancementCalculatorModel>().edition,
              darkMode: theme.brightness == Brightness.dark,
            ),
          );
        },
      ),
    );
  }
}
