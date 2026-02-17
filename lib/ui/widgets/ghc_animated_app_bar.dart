import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/confirmation_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_character_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_campaign_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/settings_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/app_bar_utils.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/character_header_delegates.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/campaign_selector.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// The main AppBar for the Home screen.
///
/// For pushed routes (Settings, CreateCharacter, etc.), use [GHCAppBar]
/// or [GHCSearchAppBar] instead.
class GHCAnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  const GHCAnimatedAppBar({super.key});

  @override
  State<GHCAnimatedAppBar> createState() => _GHCAnimatedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(58);
}

class _GHCAnimatedAppBarState extends State<GHCAnimatedAppBar>
    with SingleTickerProviderStateMixin {
  bool _isScrolledToTop = true;
  bool _isCalcScrolledToTop = true;
  String? _currentCharacterUuid;
  int? _currentPage;
  int? _previousPage;
  late final ValueNotifier<double> _charScrollOffsetNotifier;
  late final ScrollController _calcScrollController;
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    final charactersModel = context.read<CharactersModel>();
    _charScrollOffsetNotifier = charactersModel.charScrollOffsetNotifier;
    _calcScrollController = charactersModel.enhancementCalcScrollController;
    _charScrollOffsetNotifier.addListener(_scrollListener);
    _calcScrollController.addListener(_calcScrollListener);

    _flipController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _flipController.addListener(() {
      if (_flipController.value >= 0.5 && _previousPage != null) {
        setState(() => _previousPage = null);
      }
    });
    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipController.reset();
      }
    });
  }

  @override
  void dispose() {
    _charScrollOffsetNotifier.removeListener(_scrollListener);
    _calcScrollController.removeListener(_calcScrollListener);
    _flipController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Content only scrolls behind the pinned headers after the character
    // header fully collapses. This matches the chip bar's overlapsContent
    // trigger. In edit mode the header is fixed-height, so content overlaps
    // immediately.
    final model = context.read<CharactersModel>();
    final character = model.currentCharacter;
    final isFixedHeader = model.isEditMode && !(character?.isRetired ?? true);
    final collapseRange = isFixedHeader || character == null
        ? 0.0
        : CharacterHeaderDelegate.viewModeMaxHeight(character) -
              CharacterHeaderDelegate.minHeight;

    final isContentBehind = _charScrollOffsetNotifier.value > collapseRange;
    if (isContentBehind == !_isScrolledToTop) return;
    setState(() => _isScrolledToTop = !isContentBehind);
  }

  void _calcScrollListener() {
    if (!_calcScrollController.hasClients) return;
    if (_calcScrollController.positions.length != 1) return;

    final isScrolled = _calcScrollController.offset > 0;
    if (isScrolled == !_isCalcScrolledToTop) return;
    setState(() => _isCalcScrolledToTop = !isScrolled);
  }

  Future<void> _handleRetire(
    BuildContext context,
    CharactersModel charactersModel,
    AppModel appModel,
  ) async {
    final l10n = AppLocalizations.of(context);
    final String message =
        '${charactersModel.currentCharacter!.name} ${charactersModel.currentCharacter!.isRetired ? l10n.unretire.toLowerCase() : l10n.retire.toLowerCase()}d';
    Character? character = charactersModel.currentCharacter;
    await charactersModel.retireCurrentCharacter();
    appModel.updateTheme();
    if (!context.mounted) return;
    final theme = Theme.of(context);
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
                  textColor: ColorUtils.ensureContrast(
                    theme.colorScheme.primary,
                    theme.colorScheme.inverseSurface,
                  ),
                  onPressed: () {
                    charactersModel.toggleShowRetired(character: character);
                  },
                ),
        ),
      );
  }

  Future<void> _handleDelete(
    BuildContext context,
    CharactersModel charactersModel,
  ) async {
    final bool? result = await ConfirmationDialog.show(
      context: context,
      content: const Text('Are you sure? This cannot be undone'),
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
    );

    if (result == true && context.mounted) {
      final String characterName = charactersModel.currentCharacter!.name;
      await charactersModel.deleteCurrentCharacter();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('$characterName deleted')));
    }
  }

  Future<void> _handleDeleteCampaign(
    BuildContext context,
    TownModel townModel,
  ) async {
    final l10n = AppLocalizations.of(context);
    final bool? result = await ConfirmationDialog.show(
      context: context,
      content: Text(l10n.deleteCampaignBody),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );

    if (result == true && context.mounted) {
      final campaignName = townModel.activeCampaign?.name ?? '';
      await townModel.deleteActiveCampaign();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('$campaignName deleted')));
    }
  }

  Widget _buildTitleContent({
    required int displayPage,
    required int charactersPage,
    required int calculatorPage,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required CharactersModel charactersModel,
    required TownModel townModel,
    required EnhancementCalculatorModel enhancementCalculatorModel,
  }) {
    Widget content;
    if (kTownSheetEnabled &&
        displayPage == 0 &&
        townModel.activeCampaign != null) {
      content = GestureDetector(
        onTap: () => CampaignSelector.show(
          context: context,
          campaigns: townModel.campaigns,
          activeCampaign: townModel.activeCampaign,
          onCampaignSelected: (c) => townModel.setActiveCampaign(c),
          onCreateCampaign: () => CreateCampaignScreen.show(context, townModel),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${townModel.activeCampaign!.name} ',
              maxLines: 1,
              style: theme.textTheme.headlineMedium,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            Icon(Icons.swap_horiz_rounded),
          ],
        ),
      );
    } else if (displayPage == charactersPage &&
        charactersModel.characters.length > 1) {
      content = SmoothPageIndicator(
        controller: charactersModel.pageController,
        count: charactersModel.characters.length,
        effect: ScrollingDotsEffect(
          fixedCenter: true,
          dotHeight: 10,
          dotWidth: 10,
          activeDotColor: colorScheme.primary,
        ),
      );
    } else if (displayPage == calculatorPage) {
      content = SegmentedButton<GameEdition>(
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
        ),
        showSelectedIcon: false,
        segments: const [
          ButtonSegment<GameEdition>(
            value: GameEdition.gloomhaven,
            label: Text('GH'),
          ),
          ButtonSegment<GameEdition>(
            value: GameEdition.gloomhaven2e,
            label: Text('GH2e'),
          ),
          ButtonSegment<GameEdition>(
            value: GameEdition.frosthaven,
            label: Text('FH'),
          ),
        ],
        selected: {enhancementCalculatorModel.edition},
        onSelectionChanged: (Set<GameEdition> selection) {
          enhancementCalculatorModel.gameEdition = selection.first;
          setState(() {});
        },
      );
    } else {
      content = Container();
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final enhancementCalculatorModel = context
        .read<EnhancementCalculatorModel>();
    final theme = Theme.of(context);
    final appModel = context.watch<AppModel>();
    final charactersModel = context.watch<CharactersModel>();
    final townModel = context.watch<TownModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isRetired = charactersModel.currentCharacter?.isRetired ?? false;

    const charactersPage = kTownSheetEnabled ? 1 : 0;
    const calculatorPage = kTownSheetEnabled ? 2 : 1;

    // Reset tint state when switching characters so the new screen starts clean.
    final uuid = charactersModel.currentCharacter?.uuid;
    if (uuid != _currentCharacterUuid) {
      _currentCharacterUuid = uuid;
      _isScrolledToTop = true;
    }

    // When the page changes, read the target page's scroll position so the
    // tint state is correct immediately (before any scroll events fire).
    if (appModel.page != _currentPage) {
      if (_currentPage != null) {
        _previousPage = _currentPage;
        _flipController.forward(from: 0.0);
      }
      _currentPage = appModel.page;
      if (appModel.page == charactersPage) {
        final isFixedHeader =
            charactersModel.isEditMode &&
            !(charactersModel.currentCharacter?.isRetired ?? true);
        final collapseRange = isFixedHeader ? 0.0 : 124.0;
        _isScrolledToTop = _charScrollOffsetNotifier.value <= collapseRange;
      } else if (appModel.page == calculatorPage) {
        _isCalcScrolledToTop =
            !_calcScrollController.hasClients ||
            _calcScrollController.offset <= 0;
      }
    }

    final isOnCharactersPage = appModel.page == charactersPage;
    final isOnCalcPage = appModel.page == calculatorPage;
    final showTint =
        (isOnCharactersPage && !_isScrolledToTop) ||
        (isOnCalcPage && !_isCalcScrolledToTop);

    return TweenAnimationBuilder<double>(
      key: ValueKey(uuid),
      tween: Tween<double>(end: showTint ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, tintProgress, _) {
        return AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color.lerp(
            colorScheme.surface,
            AppBarUtils.getTintedBackground(colorScheme),
            tintProgress,
          ),
          centerTitle: true,
          title: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (_, child) {
              // 0→0.5: rotation ramps 0→pi/2 (old content folds away)
              // 0.5→1: rotation ramps pi/2→0 (new content folds in)
              final t = _flipAnimation.value;
              final rotation = t <= 0.5 ? t * pi : (1.0 - t) * pi;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(rotation),
                child: child,
              );
            },
            child: _buildTitleContent(
              displayPage: _previousPage ?? appModel.page,
              charactersPage: charactersPage,
              calculatorPage: calculatorPage,
              theme: theme,
              colorScheme: colorScheme,
              charactersModel: charactersModel,
              townModel: townModel,
              enhancementCalculatorModel: enhancementCalculatorModel,
            ),
          ),
          actions: <Widget>[
            // Town page edit mode: delete campaign
            if (kTownSheetEnabled && townModel.isEditMode && appModel.page == 0)
              Tooltip(
                message: l10n.deleteCampaign,
                child: IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: () => _handleDeleteCampaign(context, townModel),
                ),
              ),
            if (!charactersModel.isEditMode &&
                appModel.page == charactersPage &&
                charactersModel.characters.isNotEmpty)
              Tooltip(
                message: 'New Character',
                child: IconButton(
                  icon: const Icon(Icons.person_add_rounded),
                  onPressed: () async {
                    await CreateCharacterScreen.show(context, charactersModel);
                  },
                ),
              ),
            if (charactersModel.isEditMode &&
                appModel.page == charactersPage) ...[
              Tooltip(
                message: isRetired ? l10n.unretire : l10n.retire,
                child: IconButton(
                  icon: Icon(
                    isRetired ? Icons.work_rounded : Icons.work_off_rounded,
                  ),
                  onPressed: () =>
                      _handleRetire(context, charactersModel, appModel),
                ),
              ),
              Tooltip(
                message: l10n.delete,
                child: IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: () => _handleDelete(context, charactersModel),
                ),
              ),
            ],
            Tooltip(
              message: l10n.settings,
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
