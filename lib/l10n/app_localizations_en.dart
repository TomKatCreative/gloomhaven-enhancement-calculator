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
  String get supportAndFeedback => 'Support & Feedback';

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
  String get battleGoalCheckmarks => 'Battle Goal Checkmarks';

  @override
  String get cardLevel => 'Card Level';

  @override
  String get previousEnhancements => 'Previous Enhancements';

  @override
  String get enhancementType => 'Enhancement Type';

  @override
  String get discountsAndSettings => 'Discounts & Settings';

  @override
  String get enhancementCalculator => 'Enhancement Calculator';

  @override
  String get enhancementGuidelines => 'Enhancement Guidelines';

  @override
  String get type => 'Type';

  @override
  String get multipleTargets => 'Multiple Targets';

  @override
  String get generalGuidelines => 'General Guidelines';

  @override
  String get scenario114Reward => 'Scenario 114 Reward';

  @override
  String get forgottenCirclesSpoilers => 'Forgotten Circles spoilers';

  @override
  String get temporaryEnhancement => 'Temporary Enhancement †';

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
  String get hailsDiscount => 'Hail\'s Discount ‡';

  @override
  String get lossNonPersistent => 'Loss non-persistent';

  @override
  String get persistent => 'Persistent';

  @override
  String get eligibleFor => 'Eligible For';

  @override
  String get gameplay => 'GAMEPLAY';

  @override
  String get display => 'DISPLAY';

  @override
  String get backupAndRestore => 'BACKUP & RESTORE';

  @override
  String get testing => 'TESTING';

  @override
  String get customClasses => 'Custom Classes';

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
  String get useInterFont => 'Use Inter Font';

  @override
  String get useInterFontDescription =>
      'Replace stylized fonts with Inter to improve readability';

  @override
  String get showRetiredCharacters => 'Show Retired Characters';

  @override
  String get showRetiredCharactersDescription =>
      'Toggle visibility of retired characters in the Characters tab to reduce clutter';

  @override
  String get backup => 'Backup';

  @override
  String get backupDescription => 'Backup your current characters';

  @override
  String get restore => 'Restore';

  @override
  String get restoreDescription => 'Restore your characters from a backup file';

  @override
  String get backupFileWarning =>
      'If another backup file already exists in the Downloads folder with the same name, it will be overwritten';

  @override
  String get filename => 'Filename';

  @override
  String savedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String get backupError => 'Failed to create backup. Please try again.';

  @override
  String get restoreWarning =>
      'Restoring a backup file will overwrite any current characters. Do you wish to continue?';

  @override
  String get errorDuringRestore => 'Error During Restore Operation';

  @override
  String restoreErrorMessage(String error) {
    return 'There was an error during the restoration process. Your existing data was saved and your backup hasn\'t been modified. Please contact the developer (through the Settings menu) with your existing backup file and this information:\n\n$error';
  }

  @override
  String get createAll => 'Create All';

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
}
