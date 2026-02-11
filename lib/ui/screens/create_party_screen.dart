import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';

/// Bottom sheet for creating a new party.
class CreatePartySheet extends StatefulWidget {
  final TownModel townModel;

  const CreatePartySheet({super.key, required this.townModel});

  /// Shows the create party sheet as a modal bottom sheet.
  static Future<bool?> show(BuildContext context, TownModel model) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CreatePartySheet(townModel: model),
    );
  }

  @override
  State<CreatePartySheet> createState() => _CreatePartySheetState();
}

class _CreatePartySheetState extends State<CreatePartySheet> {
  final _nameController = TextEditingController();
  final _reputationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _reputationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          largePadding,
          largePadding,
          largePadding,
          MediaQuery.of(context).viewInsets.bottom + largePadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Text(l10n.createParty, style: theme.textTheme.titleLarge),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _onCreatePressed,
                    icon: const Icon(Icons.group_add_rounded),
                    label: Text(l10n.create),
                  ),
                ],
              ),
              const Divider(height: dividerThickness),
              const SizedBox(height: largePadding),
              // Party name
              TextFormField(
                autofocus: true,
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
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                ],
              ),
              const SizedBox(height: largePadding),
            ],
          ),
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
