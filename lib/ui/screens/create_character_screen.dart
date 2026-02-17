import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/personal_quest_selector_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/class_selector_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/create_character/edition_toggle.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/create_character/name_field.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/create_character/level_and_prosperity_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_party_sheet.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/party_assignment_sheet.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';
import 'package:provider/provider.dart';

/// A full-page screen for creating new characters.
class CreateCharacterScreen extends StatefulWidget {
  final CharactersModel charactersModel;

  const CreateCharacterScreen({super.key, required this.charactersModel});

  /// Shows the create character screen as a full page route.
  static Future<bool?> show(BuildContext context, CharactersModel model) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCharacterScreen(charactersModel: model),
      ),
    );
  }

  @override
  CreateCharacterScreenState createState() => CreateCharacterScreenState();
}

class CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final TextEditingController _nameTextFieldController =
      TextEditingController();
  final TextEditingController _classTextFieldController =
      TextEditingController();
  final TextEditingController _personalQuestTextFieldController =
      TextEditingController();
  final TextEditingController _partyTextFieldController =
      TextEditingController();

  final _nameFieldKey = GlobalKey<NameFieldState>();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  GameEdition _selectedEdition = GameEdition.gloomhaven;
  PlayerClass? _selectedClass;
  Variant _variant = Variant.base;
  int _selectedLevel = 1;
  int _selectedProsperityLevel = 1;
  int _previousRetirements = 0;
  String? _selectedPersonalQuestId;
  String? _selectedPartyId;

  @override
  void dispose() {
    _nameTextFieldController.dispose();
    _classTextFieldController.dispose();
    _personalQuestTextFieldController.dispose();
    _partyTextFieldController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GHCAppBar(
        scrollController: _scrollController,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: largePadding),
            child: TextButton.icon(
              icon: const Icon(Icons.how_to_reg_rounded),
              label: Text(AppLocalizations.of(context).create),
              style: TextButton.styleFrom(
                foregroundColor: theme.contrastedPrimary,
              ),
              onPressed: _selectedClass != null ? _onCreatePressed : null,
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
            EditionToggle(
              selectedEdition: _selectedEdition,
              onEditionChanged: (edition) {
                setState(() => _selectedEdition = edition);
              },
            ),
            const SizedBox(height: formFieldSpacing),
            NameField(
              key: _nameFieldKey,
              nameController: _nameTextFieldController,
              previousRetirements: _previousRetirements,
              onRetirementChanged: (value) {
                setState(() => _previousRetirements = value);
              },
            ),
            const SizedBox(height: formFieldSpacing),
            _buildClassSelector(context, theme),
            const SizedBox(height: formFieldSpacing),
            _buildPersonalQuestSelector(context),
            if (kTownSheetEnabled) ...[
              const SizedBox(height: formFieldSpacing),
              _buildPartySelector(context),
            ],
            const SizedBox(height: formFieldSpacing),
            LevelAndProsperitySection(
              edition: _selectedEdition,
              level: _selectedLevel,
              prosperityLevel: _selectedProsperityLevel,
              onLevelChanged: (value) {
                setState(() => _selectedLevel = value);
              },
              onProsperityChanged: (value) {
                setState(() => _selectedProsperityLevel = value);
              },
            ),
            const SizedBox(height: formFieldSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelector(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            controller: _classTextFieldController,
            decoration: InputDecoration(
              labelText: _variant != Variant.base
                  ? '${AppLocalizations.of(context).classWithVariant(ClassVariants.classVariants[_variant]!)} *'
                  : '${AppLocalizations.of(context).class_} *',
              hintText: AppLocalizations.of(context).selectClass,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.chevron_right_rounded),
            ),
            onTap: () async {
              SelectedPlayerClass? selectedPlayerClass =
                  await ClassSelectorScreen.show(context);
              if (selectedPlayerClass != null) {
                if (!context.mounted) return;
                _nameFieldKey.currentState?.requestFocus(context);

                setState(() {
                  // Mercenary Pack classes pre-populate the name field
                  if (selectedPlayerClass.playerClass.category ==
                      ClassCategory.mercenaryPacks) {
                    _nameTextFieldController.text =
                        selectedPlayerClass.playerClass.name;
                  }
                  _variant = selectedPlayerClass.variant!;
                  _classTextFieldController.text = selectedPlayerClass
                      .playerClass
                      .getDisplayName(_variant);
                  _selectedClass = selectedPlayerClass.playerClass;
                });
              }
            },
          ),
        ),
        if (_selectedClass != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: mediumPadding),
            child: SizedBox(
              width: iconSizeXL,
              height: iconSizeXL,
              child: ClassIconSvg(
                playerClass: _selectedClass!,
                color: ColorUtils.ensureContrast(
                  Color(_selectedClass!.primaryColor),
                  theme.colorScheme.surface,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPersonalQuestSelector(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: _personalQuestTextFieldController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).personalQuest,
        hintText: AppLocalizations.of(context).selectPersonalQuest,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: const OutlineInputBorder(),
        suffixIcon: _selectedPersonalQuestId != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _selectedPersonalQuestId = null;
                    _personalQuestTextFieldController.clear();
                  });
                },
              )
            : const Icon(Icons.chevron_right_rounded),
      ),
      onTap: () async {
        final result = await PersonalQuestSelectorScreen.show(context);
        if (result is PQSelected) {
          setState(() {
            _selectedPersonalQuestId = result.quest.id;
            _personalQuestTextFieldController.text = result.quest.displayName;
          });
        }
      },
    );
  }

  Widget _buildPartySelector(BuildContext context) {
    final townModel = context.read<TownModel>();
    final hasCampaign = townModel.activeCampaign != null;

    if (!hasCampaign) return const SizedBox.shrink();

    return TextFormField(
      readOnly: true,
      controller: _partyTextFieldController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).party,
        hintText: AppLocalizations.of(context).selectParty,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: const OutlineInputBorder(),
        suffixIcon: _selectedPartyId != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _selectedPartyId = null;
                    _partyTextFieldController.clear();
                  });
                },
              )
            : const Icon(Icons.chevron_right_rounded),
      ),
      onTap: () {
        PartyAssignmentSheet.show(
          context: context,
          parties: townModel.parties,
          currentPartyId: _selectedPartyId,
          onPartySelected: (partyId) {
            setState(() {
              _selectedPartyId = partyId;
              if (partyId == null) {
                _partyTextFieldController.clear();
              } else {
                final party = townModel.parties.firstWhere(
                  (p) => p.id == partyId,
                );
                _partyTextFieldController.text = party.name;
              }
            });
          },
          onCreateParty: () async {
            final created = await CreatePartySheet.show(context, townModel);
            if (created == true && townModel.activeParty != null) {
              setState(() {
                _selectedPartyId = townModel.activeParty!.id;
                _partyTextFieldController.text = townModel.activeParty!.name;
              });
            }
          },
        );
      },
    );
  }

  Future<void> _onCreatePressed() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      await widget.charactersModel.createCharacter(
        _nameFieldKey.currentState!.effectiveName,
        _selectedClass!,
        initialLevel: _selectedLevel,
        previousRetirements: _previousRetirements,
        edition: _selectedEdition,
        prosperityLevel: _selectedProsperityLevel,
        variant: _variant,
        personalQuestId: _selectedPersonalQuestId,
        partyId: kTownSheetEnabled ? _selectedPartyId : null,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
}
