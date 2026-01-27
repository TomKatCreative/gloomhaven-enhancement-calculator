import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:gloomhaven_enhancement_calc/utils/utils.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

class CreateCharacterDialog extends StatefulWidget {
  final CharactersModel charactersModel;

  const CreateCharacterDialog({super.key, required this.charactersModel});

  @override
  CreateCharacterDialogState createState() => CreateCharacterDialogState();
}

class CreateCharacterDialogState extends State<CreateCharacterDialog> {
  final TextEditingController _nameTextFieldController =
      TextEditingController();
  final TextEditingController _classTextFieldController =
      TextEditingController();
  final TextEditingController _personalGoalTextFieldController =
      TextEditingController();
  final TextEditingController _levelTextFieldController =
      TextEditingController();
  final TextEditingController _previousRetirementsTextFieldController =
      TextEditingController();
  final TextEditingController _prosperityLevelTextFieldController =
      TextEditingController();
  bool _gloomhavenMode = true;
  PlayerClass? _selectedClass;
  late faker.Faker _faker;
  late String placeholderName;
  FocusNode nameFocusNode = FocusNode();
  Variant _variant = Variant.base;

  final _formKey = GlobalKey<FormState>();
  final GlobalKey _levelKey = LabeledGlobalKey("button_icon");
  late Size buttonSize;
  late Offset buttonPosition;
  bool isLevelMenuOpen = false;
  bool isPersonalGoalMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _faker = faker.Faker();
    _levelTextFieldController.text = '1';
    placeholderName = _generateRandomName();
  }

  @override
  void dispose() {
    _nameTextFieldController.dispose();
    _classTextFieldController.dispose();
    _personalGoalTextFieldController.dispose();
    _levelTextFieldController.dispose();
    _previousRetirementsTextFieldController.dispose();
    _prosperityLevelTextFieldController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  String _generateRandomName() {
    return '${_faker.person.firstName()} ${_faker.person.lastName()}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        constraints: const BoxConstraints(
          maxWidth: maxDialogWidth,
          minWidth: maxDialogWidth,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                minVerticalPadding: 0,
                contentPadding: EdgeInsets.zero,
                title: TextFormField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  autocorrect: false,
                  focusNode: nameFocusNode,
                  decoration: InputDecoration(
                    hintText: placeholderName,
                    labelText: AppLocalizations.of(context).name,
                    border: const OutlineInputBorder(),
                  ),
                  controller: _nameTextFieldController,
                  onChanged: (value) {
                    setState(() {
                      placeholderName = value;
                      _nameTextFieldController.text = value;
                    });
                  },
                ),
                trailing: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.dice),
                  onPressed: () {
                    _nameTextFieldController.clear();
                    FocusScope.of(context).requestFocus(nameFocusNode);
                    setState(() {
                      placeholderName = _generateRandomName();
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
                title: TextFormField(
                  validator: (value) => _selectedClass == null
                      ? AppLocalizations.of(context).pleaseSelectClass
                      : null,
                  readOnly: true,
                  controller: _classTextFieldController,
                  decoration: InputDecoration(
                    // hintText: 'Class',
                    border: const OutlineInputBorder(),
                    labelText: _variant != Variant.base
                        ? AppLocalizations.of(context).classWithVariant(
                            ClassVariants.classVariants[_variant]!,
                          )
                        : AppLocalizations.of(context).class_,
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
                      FocusScope.of(context).requestFocus(nameFocusNode);

                      setState(() {
                        // Mercenary Pack classes pre-populate the name field
                        // with the name of the Mercenary
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
                trailing: SizedBox(
                  width: 48,
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _selectedClass == null
                        ? const Icon(Icons.open_in_new)
                        : SvgPicture.asset(
                            'images/class_icons/${_selectedClass!.icon}',
                            colorFilter: ColorFilter.mode(
                              Color(_selectedClass!.primaryColor),
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
                title: TextFormField(
                  enableInteractiveSelection: false,
                  key: _levelKey,
                  controller: _levelTextFieldController,
                  readOnly: true,
                  onTap: () async => await _showLevelGridDialog(context),
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    suffixIconConstraints: const BoxConstraints(
                      maxHeight: 0,
                      minWidth: 48,
                    ),
                    labelText: AppLocalizations.of(context).startingLevel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                trailing: SizedBox(
                  width: 48,
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      'images/ui/level.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
                title: TextFormField(
                  enableInteractiveSelection: false,
                  controller: _previousRetirementsTextFieldController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).previousRetirements,
                    border: const OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp('[\\.|\\,|\\ |\\-]'),
                    ),
                  ],
                  keyboardType: TextInputType.number,
                ),
              ),
              if (!_gloomhavenMode) ...[
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  minVerticalPadding: 0,
                  title: HighlightedWidget(
                    color: const Color(0xff6ab7ff),
                    child: TextFormField(
                      enableInteractiveSelection: false,
                      controller: _prosperityLevelTextFieldController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).prosperityLevel,
                        border: const OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                          RegExp('[\\.|\\,|\\ |\\-]'),
                        ),
                      ],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: mediumPadding),
              ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
                visualDensity: VisualDensity.compact,
                leading: IconButton(
                  icon: const Icon(Icons.info_outline_rounded),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) {
                      return InfoDialog(
                        title: Strings.newCharacterInfoTitle,
                        message: Strings.newCharacterInfoBody(
                          context,
                          edition: _gloomhavenMode
                              ? GameEdition.gloomhaven
                              : GameEdition.frosthaven,
                          darkMode:
                              Theme.of(context).brightness == Brightness.dark,
                        ),
                      );
                    },
                  ),
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        AppLocalizations.of(context).gloomhaven,
                        minFontSize: 8,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _gloomhavenMode ? null : Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Switch(
                        inactiveThumbImage: const AssetImage(
                          'images/branding/switch_gh.png',
                        ),
                        activeThumbColor: const Color(0xff005cb2),
                        trackColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? const Color(0xff6ab7ff)
                              : const Color(0xffa98274),
                        ),
                        value: !_gloomhavenMode,
                        onChanged: (_) {
                          setState(() {
                            if (!_gloomhavenMode) {
                              _prosperityLevelTextFieldController.clear();
                            }
                            _gloomhavenMode = !_gloomhavenMode;
                          });
                        },
                      ),
                    ),
                    Flexible(
                      child: AutoSizeText(
                        AppLocalizations.of(context).frosthaven,
                        minFontSize: 8,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _gloomhavenMode ? Colors.grey : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton.icon(
          style: Theme.of(context).textButtonTheme.style?.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) => Colors.green.withValues(alpha: 0.75),
            ),
          ),
          onPressed: () async {
            if (_formKey.currentState != null &&
                _formKey.currentState!.validate()) {
              await widget.charactersModel.createCharacter(
                _nameTextFieldController.text.isEmpty
                    ? placeholderName
                    : _nameTextFieldController.text,
                _selectedClass!,
                initialLevel: int.parse(_levelTextFieldController.text),
                previousRetirements:
                    _previousRetirementsTextFieldController.text.isEmpty
                    ? 0
                    : int.parse(_previousRetirementsTextFieldController.text),
                gloomhavenMode: _gloomhavenMode,
                prosperityLevel: _prosperityLevelTextFieldController.text != ''
                    ? int.parse(_prosperityLevelTextFieldController.text)
                    : 0,
                variant: _variant,
              );
              if (!context.mounted) return;
              Navigator.pop(context, true);
            }
          },
          label: Text(
            AppLocalizations.of(context).create,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          icon: const Icon(Icons.check_rounded, color: Colors.white),
        ),
      ],
    );
  }

  // Function to show the dialog with a grid of numbers representing the Character's starting level.
  Future<void> _showLevelGridDialog(BuildContext context) async {
    final int? result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: SvgPicture.asset(
            'images/ui/level.svg',
            width: iconSize + 5,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
          content: SizedBox(
            width: 100,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (BuildContext context, int index) {
                final number = index + 1;
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop(number);
                  },
                  child: Center(child: Text(number.toString())),
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _levelTextFieldController.text = result.toString();
      });
    }
  }
}
