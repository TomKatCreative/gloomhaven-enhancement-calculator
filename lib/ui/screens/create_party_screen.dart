import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';

/// A full-page screen for creating a new party.
class CreatePartyScreen extends StatefulWidget {
  final TownModel townModel;

  const CreatePartyScreen({super.key, required this.townModel});

  /// Shows the create party screen as a full page route.
  static Future<bool?> show(BuildContext context, TownModel model) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreatePartyScreen(townModel: model)),
    );
  }

  @override
  State<CreatePartyScreen> createState() => _CreatePartyScreenState();
}

class _CreatePartyScreenState extends State<CreatePartyScreen> {
  final _nameController = TextEditingController();
  final _reputationController = TextEditingController();
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _reputationController.dispose();
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
            // Party name
            TextFormField(
              autofocus: true,
              focusNode: _nameFocusNode,
              textCapitalization: TextCapitalization.words,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.partyName,
                hintText: 'The Heroes',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: const OutlineInputBorder(),
              ),
              controller: _nameController,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? l10n.name : null,
            ),
            const SizedBox(height: formFieldSpacing),
            // Starting reputation
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.startingReputation,
                hintText: '0',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.thumb_up_alt_outlined),
              ),
              controller: _reputationController,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
              ],
            ),
            const SizedBox(height: formFieldSpacing),
          ],
        ),
      ),
    );
  }

  Future<void> _onCreatePressed() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      final reputation = _reputationController.text.isNotEmpty
          ? int.parse(_reputationController.text)
          : 0;

      await widget.townModel.createParty(
        name: _nameController.text.trim(),
        startingReputation: reputation.clamp(-20, 20),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
}
