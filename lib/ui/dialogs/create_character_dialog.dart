import 'package:faker/faker.dart' as faker;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gloomhaven_enhancement_calc/custom_search_delegate.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

/// A modal bottom sheet for creating new characters.
/// Material 3 compliant with drag handle, scrollable form, and fixed action buttons.
class CreateCharacterSheet extends StatefulWidget {
  final CharactersModel charactersModel;

  const CreateCharacterSheet({super.key, required this.charactersModel});

  /// Shows the create character sheet as a modal bottom sheet.
  static Future<bool?> show(BuildContext context, CharactersModel model) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        top: false,
        bottom: true,
        child: CreateCharacterSheet(charactersModel: model),
      ),
    );
  }

  @override
  CreateCharacterSheetState createState() => CreateCharacterSheetState();
}

class CreateCharacterSheetState extends State<CreateCharacterSheet> {
  final TextEditingController _nameTextFieldController =
      TextEditingController();
  final TextEditingController _classTextFieldController =
      TextEditingController();
  final TextEditingController _previousRetirementsTextFieldController =
      TextEditingController();
  final TextEditingController _prosperityLevelTextFieldController =
      TextEditingController();

  GameEdition _selectedEdition = GameEdition.gloomhaven;
  PlayerClass? _selectedClass;
  late faker.Faker _faker;
  late String _placeholderName;
  final FocusNode _nameFocusNode = FocusNode();
  Variant _variant = Variant.base;
  int _selectedLevel = 1;

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
    _previousRetirementsTextFieldController.dispose();
    _prosperityLevelTextFieldController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  String _generateRandomName() {
    return '${_faker.person.firstName()} ${_faker.person.lastName()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            children: [
              // Fixed header section
              _buildHeader(context, theme, colorScheme),
              // Scrollable form content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(largePadding),
                    children: [
                      _buildNameField(context, theme),
                      const SizedBox(height: 20),
                      _buildClassSelector(context, theme),
                      const SizedBox(height: 20),
                      _buildLevelSelector(context, theme, colorScheme),
                      const SizedBox(height: 20),
                      _buildRetirementsAndProsperityRow(context, theme),
                      const SizedBox(height: 20),
                      _buildEditionToggle(context, theme),
                      // Extra bottom padding for scrolling past last field
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Fixed action buttons at bottom
              _buildActionButtons(context, theme, colorScheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.only(bottom: mediumPadding),
            child: Text(
              AppLocalizations.of(context).createCharacter,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          Divider(height: 1, color: theme.dividerTheme.color),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(
    BuildContext context,
    ThemeData theme,
    String label,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: mediumPadding),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          context,
          theme,
          AppLocalizations.of(context).name,
          Icons.person_outline,
        ),
        const SizedBox(height: mediumPadding),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                autocorrect: false,
                focusNode: _nameFocusNode,
                decoration: InputDecoration(
                  hintText: _placeholderName,
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
            const SizedBox(width: mediumPadding),
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
          ],
        ),
      ],
    );
  }

  Widget _buildClassSelector(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          context,
          theme,
          _variant != Variant.base
              ? AppLocalizations.of(
                  context,
                ).classWithVariant(ClassVariants.classVariants[_variant]!)
              : AppLocalizations.of(context).class_,
          Icons.shield_outlined,
        ),
        const SizedBox(height: mediumPadding),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                validator: (value) => _selectedClass == null
                    ? AppLocalizations.of(context).pleaseSelectClass
                    : null,
                readOnly: true,
                controller: _classTextFieldController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).selectClass,
                  suffixIcon: const Icon(Icons.chevron_right),
                ),
                onTap: () async {
                  SelectedPlayerClass? selectedPlayerClass =
                      await showSearch<SelectedPlayerClass>(
                        context: context,
                        delegate: CustomSearchDelegate(
                          PlayerClasses.playerClasses,
                        ),
                      );
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
                    _formKey.currentState?.validate();
                  }
                },
              ),
            ),
            const SizedBox(width: mediumPadding),
            SizedBox(
              width: 48,
              height: 48,
              child: _selectedClass == null
                  ? Icon(
                      Icons.help_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                    )
                  : SvgPicture.asset(
                      'images/class_icons/${_selectedClass!.icon}',
                      colorFilter: ColorFilter.mode(
                        Color(_selectedClass!.primaryColor),
                        BlendMode.srcIn,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelSelector(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          context,
          theme,
          '${AppLocalizations.of(context).startingLevel}: $_selectedLevel',
          Icons.trending_up,
        ),
        const SizedBox(height: mediumPadding),
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

  Widget _buildRetirementsAndProsperityRow(
    BuildContext context,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Previous Retirements
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(
                context,
                theme,
                AppLocalizations.of(context).previousRetirements,
                Icons.elderly,
              ),
              const SizedBox(height: mediumPadding),
              TextFormField(
                enableInteractiveSelection: false,
                controller: _previousRetirementsTextFieldController,
                decoration: InputDecoration(
                  hintText: '0',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp('[\\.|\\,|\\ |\\-]')),
                ],
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        const SizedBox(width: largePadding),
        // Prosperity Level (used by GH2E and Frosthaven)
        Expanded(
          child: Opacity(
            opacity: _selectedEdition == GameEdition.gloomhaven ? 0.4 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(
                  context,
                  theme,
                  AppLocalizations.of(context).prosperityLevel,
                  Icons.location_city,
                ),
                const SizedBox(height: mediumPadding),
                TextFormField(
                  enabled: _selectedEdition != GameEdition.gloomhaven,
                  enableInteractiveSelection: false,
                  controller: _prosperityLevelTextFieldController,
                  decoration: InputDecoration(
                    hintText: '0',
                    ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp('[\\.|\\,|\\ |\\-]'),
                    ),
                  ],
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditionToggle(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => showDialog<void>(
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
            ),
            Text(
              AppLocalizations.of(context).gameEdition,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: mediumPadding),
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
                label: const Text('GH2E'),
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
                // Clear prosperity when switching to original GH
                if (newEdition == GameEdition.gloomhaven) {
                  _prosperityLevelTextFieldController.clear();
                }
                _selectedEdition = newEdition;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(largePadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: theme.dividerTheme.color ?? Colors.grey),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          const SizedBox(width: mediumPadding),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: Text(AppLocalizations.of(context).create),
            onPressed: _onCreatePressed,
          ),
        ],
      ),
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
        previousRetirements:
            _previousRetirementsTextFieldController.text.isEmpty
            ? 0
            : int.parse(_previousRetirementsTextFieldController.text),
        edition: _selectedEdition,
        prosperityLevel: _prosperityLevelTextFieldController.text != ''
            ? int.parse(_prosperityLevelTextFieldController.text)
            : 0,
        variant: _variant,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
}
