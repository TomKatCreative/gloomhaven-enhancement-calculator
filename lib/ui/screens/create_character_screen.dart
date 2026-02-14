import 'package:faker/faker.dart' as faker;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/personal_quest_selector_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/class_selector_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/labeled_text_field.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_party_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/party_assignment_sheet.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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

  GameEdition _selectedEdition = GameEdition.gloomhaven;
  PlayerClass? _selectedClass;
  late faker.Faker _faker;
  late String _placeholderName;
  final FocusNode _nameFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Variant _variant = Variant.base;
  int _selectedLevel = 1;
  int _selectedProsperityLevel = 1;
  int _previousRetirements = 0;
  String? _selectedPersonalQuestId;
  String? _selectedPartyId;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _faker = faker.Faker();
    _placeholderName = _generateRandomName();
  }

  @override
  void dispose() {
    _nameTextFieldController.dispose();
    _classTextFieldController.dispose();
    _personalQuestTextFieldController.dispose();
    _partyTextFieldController.dispose();
    _nameFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _generateRandomName() {
    return '${_faker.person.firstName()} ${_faker.person.lastName()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            _buildEditionToggle(context, theme),
            const SizedBox(height: formFieldSpacing),
            _buildNameField(context, theme),
            const SizedBox(height: formFieldSpacing),
            _buildClassSelector(context, theme),
            const SizedBox(height: formFieldSpacing),
            _buildPersonalQuestSelector(context, theme),
            if (kTownSheetEnabled) ...[
              const SizedBox(height: formFieldSpacing),
              _buildPartySelector(context, theme),
            ],
            const SizedBox(height: formFieldSpacing),
            _buildProsperitySelector(context, theme, colorScheme),
            const SizedBox(height: formFieldSpacing),
            _buildLevelSelector(context, theme, colorScheme),
            const SizedBox(height: formFieldSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            textCapitalization: TextCapitalization.words,
            autocorrect: false,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              labelText: l10n.name,
              hintText: _placeholderName,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: const OutlineInputBorder(),
            ),
            controller: _nameTextFieldController,
            onChanged: (value) {
              setState(() {
                _placeholderName = value;
                _nameTextFieldController.text = value;
              });
            },
          ),
        ),
        const SizedBox(width: smallPadding),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.dice),
          tooltip: 'Generate random name',
          onPressed: () {
            _nameTextFieldController.clear();
            FocusScope.of(context).requestFocus(_nameFocusNode);
            setState(() {
              _placeholderName = _generateRandomName();
            });
          },
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: iconSizeSmall,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(tinyPadding),
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _previousRetirements > 0
                      ? () => setState(() => _previousRetirements--)
                      : null,
                ),
                IntrinsicWidth(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Opacity(opacity: 0, child: Text('66')),
                      Text(
                        '$_previousRetirements',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: iconSizeSmall,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(tinyPadding),
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _previousRetirements < 99
                      ? () => setState(() => _previousRetirements++)
                      : null,
                ),
              ],
            ),
            Text(
              l10n.retirements,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
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
                FocusScope.of(context).requestFocus(_nameFocusNode);

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

  Widget _buildPersonalQuestSelector(BuildContext context, ThemeData theme) {
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

  Widget _buildPartySelector(BuildContext context, ThemeData theme) {
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

  Widget _buildLevelSelector(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);
    final maxLevel = _selectedEdition.maxStartingLevel(
      _selectedProsperityLevel,
    );
    final exceedsProsperity = _selectedLevel > maxLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ThemedSvg(
              assetKey: 'LEVEL',
              width: iconSizeMedium,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: smallPadding),
            IntrinsicWidth(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Opacity(
                    opacity: 0,
                    child: Text(
                      '${l10n.startingLevel}: 9',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${l10n.startingLevel}: $_selectedLevel',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (exceedsProsperity) ...[
              const SizedBox(width: smallPadding),
              Tooltip(
                message: l10n.levelExceedsProsperity(maxLevel),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: iconSizeSmall,
                  color: Colors.amber,
                ),
              ),
            ],
            if (_selectedEdition == GameEdition.gloomhaven)
              ..._buildGoldDisplay(theme),
          ],
        ),
        const SizedBox(height: smallPadding),
        SfSlider(
          min: 1.0,
          max: 9.0,
          value: _selectedLevel.toDouble(),
          interval: 1,
          stepSize: 1,
          showLabels: true,
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          onChanged: (dynamic value) {
            setState(() => _selectedLevel = (value as double).round());
          },
        ),
      ],
    );
  }

  Widget _buildProsperitySelector(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SectionLabel(
              label:
                  '${AppLocalizations.of(context).prosperityLevel}: $_selectedProsperityLevel',
              svgAssetKey: 'PROSPERITY',
              iconSize: iconSizeMedium,
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (_selectedEdition != GameEdition.gloomhaven)
              ..._buildGoldDisplay(theme),
          ],
        ),
        const SizedBox(height: smallPadding),
        SfSlider(
          min: 1.0,
          max: 9.0,
          value: _selectedProsperityLevel.toDouble(),
          interval: 1,
          stepSize: 1,
          showLabels: true,
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          onChanged: (dynamic value) {
            setState(
              () => _selectedProsperityLevel = (value as double).round(),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildGoldDisplay(ThemeData theme) {
    return [
      const Spacer(),
      ThemedSvg(
        assetKey: 'GOLD',
        width: iconSizeSmall,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: tinyPadding),
      IntrinsicWidth(
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Opacity(
              opacity: 0,
              child: Text('150', style: theme.textTheme.bodyMedium),
            ),
            Text(
              '${_selectedEdition.startingGold(level: _selectedLevel, prosperityLevel: _selectedProsperityLevel)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: smallPadding),
    ];
  }

  Widget _buildEditionToggle(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom label row with info button instead of standard icon
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(borderRadiusMedium),
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) {
                  return InfoDialog(
                    title: Strings.newCharacterInfoTitle,
                    message: Strings.newCharacterInfoBody(
                      context,
                      edition: _selectedEdition,
                      darkMode: theme.brightness == Brightness.dark,
                    ),
                  );
                },
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: iconSizeMedium,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: smallPadding),
            Text(
              AppLocalizations.of(context).gameEdition,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: smallPadding),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<GameEdition>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: GameEdition.gloomhaven,
                label: const Text('GH'),
                tooltip: AppLocalizations.of(context).gloomhaven,
              ),
              ButtonSegment(
                value: GameEdition.gloomhaven2e,
                label: const Text('GH2e'),
                tooltip: 'Gloomhaven 2nd Edition',
              ),
              ButtonSegment(
                value: GameEdition.frosthaven,
                label: const Text('FH'),
                tooltip: AppLocalizations.of(context).frosthaven,
              ),
            ],
            selected: {_selectedEdition},
            onSelectionChanged: (Set<GameEdition> selection) {
              setState(() {
                final newEdition = selection.first;
                _selectedEdition = newEdition;
              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onCreatePressed() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      await widget.charactersModel.createCharacter(
        _nameTextFieldController.text.isEmpty
            ? _placeholderName
            : _nameTextFieldController.text,
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
