import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';

/// A full-page screen for creating a new world.
class CreateWorldScreen extends StatefulWidget {
  final TownModel townModel;

  const CreateWorldScreen({super.key, required this.townModel});

  /// Shows the create world screen as a full page route.
  static Future<bool?> show(BuildContext context, TownModel model) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateWorldScreen(townModel: model)),
    );
  }

  @override
  State<CreateWorldScreen> createState() => _CreateWorldScreenState();
}

class _CreateWorldScreenState extends State<CreateWorldScreen> {
  final _nameController = TextEditingController();
  final _prosperityController = TextEditingController();
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _prosperityController.dispose();
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
            // World name
            TextFormField(
              autofocus: true,
              focusNode: _nameFocusNode,
              textCapitalization: TextCapitalization.words,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.worldName,
                hintText: 'Gloomhaven',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: const OutlineInputBorder(),
              ),
              controller: _nameController,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? l10n.name : null,
            ),
            const SizedBox(height: formFieldSpacing),
            // Starting prosperity
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.startingProsperity,
                hintText: '0',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_city),
              ),
              controller: _prosperityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: formFieldSpacing),
          ],
        ),
      ),
    );
  }

  Future<void> _onCreatePressed() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      final prosperity = _prosperityController.text.isNotEmpty
          ? int.parse(_prosperityController.text)
          : 0;

      await widget.townModel.createWorld(
        name: _nameController.text.trim(),
        edition: GameEdition.gloomhaven,
        startingProsperityCheckmarks: prosperity,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
}
