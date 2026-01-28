import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/create_character_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/settings_screen.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GHCAppBar extends StatefulWidget implements PreferredSizeWidget {
  const GHCAppBar({super.key});

  @override
  State<GHCAppBar> createState() => _GHCAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(58);
}

class _GHCAppBarState extends State<GHCAppBar> {
  late VoidCallback _charScrollListener;
  late VoidCallback _enhancementScrollListener;

  @override
  void initState() {
    super.initState();
    final charactersModel = context.read<CharactersModel>();

    _charScrollListener = () =>
        _scrollListener(charactersModel.charScreenScrollController);
    _enhancementScrollListener = () =>
        _scrollListener(charactersModel.enhancementCalcScrollController);

    charactersModel.charScreenScrollController.addListener(_charScrollListener);
    charactersModel.enhancementCalcScrollController.addListener(
      _enhancementScrollListener,
    );
  }

  @override
  void dispose() {
    final charactersModel = context.read<CharactersModel>();
    charactersModel.charScreenScrollController.removeListener(
      _charScrollListener,
    );
    charactersModel.enhancementCalcScrollController.removeListener(
      _enhancementScrollListener,
    );
    super.dispose();
  }

  void _scrollListener(ScrollController scrollController) {
    if (scrollController.hasClients &&
        scrollController.positions.length == 1 &&
        scrollController.offset <= scrollController.position.minScrollExtent) {
      //call setState only when values are about to change
      if (!context.read<CharactersModel>().isScrolledToTop) {
        setState(() {
          //reach the top
          context.read<CharactersModel>().isScrolledToTop = true;
        });
      }
    } else {
      //call setState only when values are about to change
      if (context.read<CharactersModel>().isScrolledToTop) {
        setState(() {
          //not the top
          context.read<CharactersModel>().isScrolledToTop = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enhancementCalculatorModel = context
        .read<EnhancementCalculatorModel>();
    final appModel = context.read<AppModel>();
    final charactersModel = context.watch<CharactersModel>();
    final colorScheme = Theme.of(context).colorScheme;

    // Base and scrolled colors for tint effect
    final baseColor = colorScheme.surface;
    final scrolledColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.08),
      baseColor,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: charactersModel.isScrolledToTop ? 0.0 : 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, progress, child) {
        return AppBar(
          automaticallyImplyLeading: false,
          elevation: progress * 4.0,
          backgroundColor: Color.lerp(baseColor, scrolledColor, progress),
          centerTitle: true,
          title:
              context.watch<AppModel>().page == 0 &&
                  charactersModel.characters.length > 1
              ? SmoothPageIndicator(
                  controller: charactersModel.pageController,
                  count: charactersModel.characters.length,
                  effect: ScrollingDotsEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotColor: colorScheme.onSurface,
                  ),
                )
              : context.watch<AppModel>().page == 1
              ? SegmentedButton<GameEdition>(
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment<GameEdition>(
                      value: GameEdition.gloomhaven,
                      label: Text('Gloomhaven'),
                    ),
                    ButtonSegment<GameEdition>(
                      value: GameEdition.gloomhaven2e,
                      label: Text('Gloomhaven 2E'),
                    ),
                    ButtonSegment<GameEdition>(
                      value: GameEdition.frosthaven,
                      label: Text('Frosthaven'),
                    ),
                  ],
                  selected: {SharedPrefs().gameEdition},
                  onSelectionChanged: (Set<GameEdition> selection) {
                    SharedPrefs().gameEdition = selection.first;
                    Provider.of<EnhancementCalculatorModel>(
                      context,
                      listen: false,
                    ).gameVersionToggled();
                    setState(() {});
                  },
                )
              : Container(),
          actions: <Widget>[
            if (charactersModel.isEditMode)
              Tooltip(
                message: charactersModel.currentCharacter!.isRetired
                    ? 'Unretire'
                    : 'Retire',
                child: IconButton(
                  icon: Icon(
                    charactersModel.currentCharacter!.isRetired
                        ? Icons.directions_walk
                        : Icons.assist_walker,
                  ),
                  onPressed: () async {
                    final String message =
                        '${charactersModel.currentCharacter!.name} ${charactersModel.currentCharacter!.isRetired ? 'unretired' : 'retired'}';
                    Character? character = charactersModel.currentCharacter;
                    await charactersModel.retireCurrentCharacter();
                    appModel.updateTheme();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(message),
                          persist: false,
                          action: charactersModel.showRetired
                              ? null
                              : SnackBarAction(
                                  label: 'Show',
                                  onPressed: () {
                                    charactersModel.toggleShowRetired(
                                      character: character,
                                    );
                                  },
                                ),
                        ),
                      );
                  },
                ),
              ),
            if (appModel.page == 0)
              Tooltip(
                message: charactersModel.isEditMode
                    ? 'Delete'
                    : 'New Character',
                child: IconButton(
                  icon: Icon(
                    charactersModel.isEditMode
                        ? Icons.delete_rounded
                        : Icons.person_add_rounded,
                    color: charactersModel.isEditMode ? Colors.red[400] : null,
                  ),
                  onPressed: charactersModel.isEditMode
                      ? () {
                          showDialog<bool?>(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                content: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: maxDialogWidth,
                                    minWidth: maxDialogWidth,
                                  ),
                                  child: const Text(
                                    'Are you sure? This cannot be undone',
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  ElevatedButton.icon(
                                    style: Theme.of(context)
                                        .textButtonTheme
                                        .style
                                        ?.copyWith(
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith<
                                                Color
                                              >(
                                                (Set<WidgetState> states) =>
                                                    Colors.red.withValues(
                                                      alpha: 0.75,
                                                    ),
                                              ),
                                        ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    icon: const Icon(
                                      Icons.delete_rounded,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Delete',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ).then((bool? result) async {
                            if (result != null && result) {
                              final String characterName =
                                  charactersModel.currentCharacter!.name;
                              await charactersModel.deleteCurrentCharacter();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                ..clearSnackBars()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text('$characterName deleted'),
                                  ),
                                );
                            }
                          });
                        }
                      : () async {
                          await CreateCharacterSheet.show(
                            context,
                            charactersModel,
                          );
                        },
                ),
              ),
            Tooltip(
              message: 'Settings',
              child: IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () async {
                  charactersModel.isEditMode = false;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        enhancementCalculatorModel: enhancementCalculatorModel,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
