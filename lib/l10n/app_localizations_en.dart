// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitleIOS => 'Gloomhaven Utility';

  @override
  String get appTitleAndroid => 'Gloomhaven Companion';

  @override
  String get search => 'Search...';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get create => 'Create';

  @override
  String get continue_ => 'Continue';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get gotIt => 'Got it!';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get restoring => 'Restoring...';

  @override
  String get solve => 'Solve';

  @override
  String get unlock => 'Unlock';

  @override
  String get settings => 'Settings';

  @override
  String get changelog => 'Changelog';

  @override
  String get license => 'License';

  @override
  String get supportAndFeedback => 'Support & feedback';

  @override
  String get name => 'Name';

  @override
  String get xp => 'XP';

  @override
  String get gold => 'Gold';

  @override
  String get resources => 'Resources';

  @override
  String get notes => 'Notes';

  @override
  String get retired => '(retired)';

  @override
  String get previousRetirements => 'Previous retirements';

  @override
  String pocketItemsAllowed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count pocket item$_temp0 allowed';
  }

  @override
  String get battleGoals => 'Battle goals';

  @override
  String get cardLevel => 'Card level';

  @override
  String get previousEnhancements => 'Previous enhancements';

  @override
  String get enhancementType => 'Enhancement type';

  @override
  String get actionDetails => 'Enhancement';

  @override
  String get cardDetails => 'Card details';

  @override
  String get discounts => 'Discounts';

  @override
  String get enhancementCalculator => 'Enhancement calculator';

  @override
  String get enhancementGuidelines => 'Enhancement guidelines';

  @override
  String get type => 'Select type...';

  @override
  String get multipleTargets => 'Multiple targets';

  @override
  String get generalGuidelines => 'General guidelines';

  @override
  String get scenario114Reward => 'Scenario 114 reward';

  @override
  String get forgottenCirclesSpoilers => 'Forgotten Circles spoilers';

  @override
  String get temporaryEnhancement => 'Temporary enhancements';

  @override
  String get variant => 'Variant';

  @override
  String get building44 => 'Building 44';

  @override
  String get frosthavenSpoilers => 'Frosthaven spoilers';

  @override
  String get enhancer => 'Enhancer';

  @override
  String get lvl1 => 'Lvl 1';

  @override
  String get lvl2 => 'Lvl 2';

  @override
  String get lvl3 => 'Lvl 3';

  @override
  String get lvl4 => 'Lvl 4';

  @override
  String get buyEnhancements => 'Buy enhancements';

  @override
  String get reduceEnhancementCosts =>
      'and reduce all enhancement costs by 10 gold';

  @override
  String get reduceLevelPenalties =>
      'and reduce level penalties by 10 gold per level';

  @override
  String get reduceRepeatPenalties =>
      'and reduce repeat penalties by 25 gold per enhancement';

  @override
  String get hailsDiscount => 'Hail\'s discount';

  @override
  String get lossNonPersistent => 'Lost & non-persistent';

  @override
  String get persistent => 'Persistent';

  @override
  String get eligibleFor => 'Eligible for';

  @override
  String get gameplay => 'GAMEPLAY';

  @override
  String get display => 'DISPLAY';

  @override
  String get backupAndRestore => 'LOCAL BACKUP & RESTORE';

  @override
  String get testing => 'TESTING';

  @override
  String get customClasses => 'Custom classes';

  @override
  String get customClassesDescription =>
      'Include Crimson Scales, Trail of Ashes, and \'released\' custom classes created by the CCUG community';

  @override
  String get solveEnvelopeX => 'Solve \'Envelope X\'';

  @override
  String get gloomhavenSpoilers => 'Gloomhaven spoilers';

  @override
  String get enterSolution => 'Enter the solution to the puzzle';

  @override
  String get solution => 'Solution';

  @override
  String get bladeswarmUnlocked => 'Bladeswarm unlocked';

  @override
  String get unlockEnvelopeV => 'Unlock \'Envelope V\'';

  @override
  String get crimsonScalesSpoilers => 'Crimson Scales spoilers';

  @override
  String get enterPassword =>
      'What is the password for unlocking this envelope?';

  @override
  String get password => 'Password';

  @override
  String get vanquisherUnlocked => 'Vanquisher unlocked';

  @override
  String get brightness => 'Brightness';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get useInterFont => 'Use Inter font';

  @override
  String get useInterFontDescription =>
      'Replace stylized fonts with Inter to improve readability';

  @override
  String get showRetiredCharacters => 'Show retired characters';

  @override
  String get showRetiredCharactersDescription =>
      'Toggle visibility of retired characters in the Characters tab to reduce clutter';

  @override
  String get backup => 'Backup';

  @override
  String get backupDescription =>
      'Backup your current characters to your device';

  @override
  String get restore => 'Restore';

  @override
  String get restoreDescription =>
      'Restore your characters from a backup file on your device';

  @override
  String get filename => 'Filename';

  @override
  String saved(String filename) {
    return 'Saved $filename';
  }

  @override
  String get filenameRequired => 'Please enter a filename';

  @override
  String get backupIncludes =>
      'Your backup will include all characters, perks, masteries, and app settings (theme, calculator state, class unlocks).';

  @override
  String get backupError => 'Failed to create backup. Please try again.';

  @override
  String get restoreWarning =>
      'Restoring a backup file will overwrite all current characters and app settings (theme, calculator state, class unlocks). Do you wish to continue?';

  @override
  String get errorDuringRestore => 'Error During Restore Operation';

  @override
  String restoreErrorMessage(String error) {
    return 'There was an error during the restoration process. Your existing data was saved and your backup hasn\'t been modified. Please contact the developer (through the Settings menu) with your existing backup file and this information:\n\n$error';
  }

  @override
  String get createAll => 'Create all';

  @override
  String get gloomhaven => 'Gloomhaven';

  @override
  String get frosthaven => 'Frosthaven';

  @override
  String get crimsonScales => 'Crimson Scales';

  @override
  String get custom => 'Custom';

  @override
  String get andVariants => '& variants';

  @override
  String createCharacterPrompt(String article) {
    return 'Create $article character using the button below, or restore a backup from the Settings menu';
  }

  @override
  String get articleA => 'a';

  @override
  String get articleYourFirst => 'your first';

  @override
  String get class_ => 'Class';

  @override
  String classWithVariant(String variant) {
    return 'Class ($variant)';
  }

  @override
  String get startingLevel => 'Starting level';

  @override
  String get prosperityLevel => 'Prosperity level';

  @override
  String get pleaseSelectClass => 'Please select a Class';

  @override
  String get createCharacter => 'Create character';

  @override
  String get gameEdition => 'Game edition';

  @override
  String get selectClass => 'Select class...';

  @override
  String get addNotes => 'Add notes...';

  @override
  String get personalQuest => 'Personal Quest';

  @override
  String get selectPersonalQuest => 'Select personal quest...';

  @override
  String get selectAPersonalQuest => 'Select a Personal Quest';

  @override
  String get changePersonalQuest => 'Change Personal Quest?';

  @override
  String get changePersonalQuestBody =>
      'This will replace your current quest and reset all progress.';

  @override
  String get comingSoon => 'Coming soon...';

  @override
  String get noPersonalQuest => 'No personal quest selected';

  @override
  String get change => 'Change';

  @override
  String progressOf(int current, int target) {
    return '$current/$target';
  }

  @override
  String get personalQuestComplete => 'Personal quest complete!';

  @override
  String personalQuestCompleteBody(String name) {
    return '$name has fulfilled their personal quest and must retire. Before retiring, consider spending gold on enhancements or donations — all gold and items are lost upon retirement. The city gains 1 prosperity.';
  }

  @override
  String get retire => 'Retire';

  @override
  String get unretire => 'Unretire';

  @override
  String get notYet => 'Not Yet';

  @override
  String get general => 'General';

  @override
  String get quest => 'Quest';

  @override
  String get perks => 'Perks';

  @override
  String get masteries => 'Masteries';

  @override
  String get questAndNotes => 'Quest & Notes';

  @override
  String get perksAndMasteries => 'Perks & Masteries';

  @override
  String get town => 'TOWN';

  @override
  String get characters => 'CHARACTERS';

  @override
  String get enhancements => 'ENHANCEMENTS';

  @override
  String get subtract => 'Subtract';

  @override
  String get add => 'Add';
}
