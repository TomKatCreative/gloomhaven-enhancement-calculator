import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

/// A full-page screen for creating a new campaign.
class CreateCampaignScreen extends StatefulWidget {
  final TownModel townModel;

  const CreateCampaignScreen({super.key, required this.townModel});

  /// Shows the create campaign screen as a full page route.
  static Future<bool?> show(BuildContext context, TownModel model) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateCampaignScreen(townModel: model)),
    );
  }

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  int _prosperityLevel = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: GHCAppBar(
        scrollController: _scrollController,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: largePadding),
            child: TextButton.icon(
              icon: const Icon(Icons.check),
              label: Text(l10n.create),
              onPressed: _onCreatePressed,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(extraLargePadding),
          children: [
            // Campaign name
            TextFormField(
              autofocus: true,
              focusNode: _nameFocusNode,
              textCapitalization: TextCapitalization.words,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.campaignName,
                hintText: 'Gloomhaven',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: const OutlineInputBorder(),
              ),
              controller: _nameController,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? l10n.name : null,
            ),
            const SizedBox(height: formFieldSpacing),
            // Starting prosperity level
            Text(
              l10n.startingProsperity,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SfSlider(
              min: 1.0,
              max: 9.0,
              value: _prosperityLevel.toDouble(),
              interval: 1,
              stepSize: 1,
              showLabels: true,
              showTicks: true,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (dynamic value) {
                setState(() {
                  _prosperityLevel = (value as double).round();
                });
              },
            ),
            const SizedBox(height: formFieldSpacing),
          ],
        ),
      ),
    );
  }

  Future<void> _onCreatePressed() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      final edition = GameEdition.gloomhaven;
      final threshold = prosperityThresholds[edition]![_prosperityLevel - 1];
      final checkmarks = threshold < 1 ? 1 : threshold;

      await widget.townModel.createCampaign(
        name: _nameController.text.trim(),
        edition: edition,
        startingProsperityCheckmarks: checkmarks,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
}
