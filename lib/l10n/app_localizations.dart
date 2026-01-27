import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitleIOS.
  ///
  /// In en, this message translates to:
  /// **'Gloomhaven Utility'**
  String get appTitleIOS;

  /// No description provided for @appTitleAndroid.
  ///
  /// In en, this message translates to:
  /// **'Gloomhaven Companion'**
  String get appTitleAndroid;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @restoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get restoring;

  /// No description provided for @solve.
  ///
  /// In en, this message translates to:
  /// **'Solve'**
  String get solve;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @changelog.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @supportAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Support & Feedback'**
  String get supportAndFeedback;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @retired.
  ///
  /// In en, this message translates to:
  /// **'(retired)'**
  String get retired;

  /// No description provided for @previousRetirements.
  ///
  /// In en, this message translates to:
  /// **'Previous retirements'**
  String get previousRetirements;

  /// No description provided for @pocketItemsAllowed.
  ///
  /// In en, this message translates to:
  /// **'{count} pocket item{count, plural, =1{} other{s}} allowed'**
  String pocketItemsAllowed(int count);

  /// No description provided for @battleGoalCheckmarks.
  ///
  /// In en, this message translates to:
  /// **'Battle Goal Checkmarks'**
  String get battleGoalCheckmarks;

  /// No description provided for @cardLevel.
  ///
  /// In en, this message translates to:
  /// **'Card Level'**
  String get cardLevel;

  /// No description provided for @previousEnhancements.
  ///
  /// In en, this message translates to:
  /// **'Previous Enhancements'**
  String get previousEnhancements;

  /// No description provided for @enhancementType.
  ///
  /// In en, this message translates to:
  /// **'Enhancement Type'**
  String get enhancementType;

  /// No description provided for @discountsAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Discounts & Settings'**
  String get discountsAndSettings;

  /// No description provided for @enhancementCalculator.
  ///
  /// In en, this message translates to:
  /// **'Enhancement Calculator'**
  String get enhancementCalculator;

  /// No description provided for @enhancementGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Enhancement Guidelines'**
  String get enhancementGuidelines;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @multipleTargets.
  ///
  /// In en, this message translates to:
  /// **'Multiple Targets'**
  String get multipleTargets;

  /// No description provided for @generalGuidelines.
  ///
  /// In en, this message translates to:
  /// **'General Guidelines'**
  String get generalGuidelines;

  /// No description provided for @scenario114Reward.
  ///
  /// In en, this message translates to:
  /// **'Scenario 114 Reward'**
  String get scenario114Reward;

  /// No description provided for @forgottenCirclesSpoilers.
  ///
  /// In en, this message translates to:
  /// **'Forgotten Circles spoilers'**
  String get forgottenCirclesSpoilers;

  /// No description provided for @temporaryEnhancement.
  ///
  /// In en, this message translates to:
  /// **'Temporary Enhancement †'**
  String get temporaryEnhancement;

  /// No description provided for @variant.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get variant;

  /// No description provided for @building44.
  ///
  /// In en, this message translates to:
  /// **'Building 44'**
  String get building44;

  /// No description provided for @frosthavenSpoilers.
  ///
  /// In en, this message translates to:
  /// **'Frosthaven spoilers'**
  String get frosthavenSpoilers;

  /// No description provided for @enhancer.
  ///
  /// In en, this message translates to:
  /// **'Enhancer'**
  String get enhancer;

  /// No description provided for @lvl1.
  ///
  /// In en, this message translates to:
  /// **'Lvl 1'**
  String get lvl1;

  /// No description provided for @lvl2.
  ///
  /// In en, this message translates to:
  /// **'Lvl 2'**
  String get lvl2;

  /// No description provided for @lvl3.
  ///
  /// In en, this message translates to:
  /// **'Lvl 3'**
  String get lvl3;

  /// No description provided for @lvl4.
  ///
  /// In en, this message translates to:
  /// **'Lvl 4'**
  String get lvl4;

  /// No description provided for @buyEnhancements.
  ///
  /// In en, this message translates to:
  /// **'Buy enhancements'**
  String get buyEnhancements;

  /// No description provided for @reduceEnhancementCosts.
  ///
  /// In en, this message translates to:
  /// **'and reduce all enhancement costs by 10 gold'**
  String get reduceEnhancementCosts;

  /// No description provided for @reduceLevelPenalties.
  ///
  /// In en, this message translates to:
  /// **'and reduce level penalties by 10 gold per level'**
  String get reduceLevelPenalties;

  /// No description provided for @reduceRepeatPenalties.
  ///
  /// In en, this message translates to:
  /// **'and reduce repeat penalties by 25 gold per enhancement'**
  String get reduceRepeatPenalties;

  /// No description provided for @hailsDiscount.
  ///
  /// In en, this message translates to:
  /// **'Hail\'s Discount ‡'**
  String get hailsDiscount;

  /// No description provided for @lossNonPersistent.
  ///
  /// In en, this message translates to:
  /// **'Loss non-persistent'**
  String get lossNonPersistent;

  /// No description provided for @persistent.
  ///
  /// In en, this message translates to:
  /// **'Persistent'**
  String get persistent;

  /// No description provided for @eligibleFor.
  ///
  /// In en, this message translates to:
  /// **'Eligible For'**
  String get eligibleFor;

  /// No description provided for @gameplay.
  ///
  /// In en, this message translates to:
  /// **'GAMEPLAY'**
  String get gameplay;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'DISPLAY'**
  String get display;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'BACKUP & RESTORE'**
  String get backupAndRestore;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'TESTING'**
  String get testing;

  /// No description provided for @customClasses.
  ///
  /// In en, this message translates to:
  /// **'Custom Classes'**
  String get customClasses;

  /// No description provided for @customClassesDescription.
  ///
  /// In en, this message translates to:
  /// **'Include Crimson Scales, Trail of Ashes, and \'released\' custom classes created by the CCUG community'**
  String get customClassesDescription;

  /// No description provided for @solveEnvelopeX.
  ///
  /// In en, this message translates to:
  /// **'Solve \'Envelope X\''**
  String get solveEnvelopeX;

  /// No description provided for @gloomhavenSpoilers.
  ///
  /// In en, this message translates to:
  /// **'Gloomhaven spoilers'**
  String get gloomhavenSpoilers;

  /// No description provided for @enterSolution.
  ///
  /// In en, this message translates to:
  /// **'Enter the solution to the puzzle'**
  String get enterSolution;

  /// No description provided for @solution.
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solution;

  /// No description provided for @bladeswarmUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Bladeswarm unlocked'**
  String get bladeswarmUnlocked;

  /// No description provided for @unlockEnvelopeV.
  ///
  /// In en, this message translates to:
  /// **'Unlock \'Envelope V\''**
  String get unlockEnvelopeV;

  /// No description provided for @crimsonScalesSpoilers.
  ///
  /// In en, this message translates to:
  /// **'Crimson Scales spoilers'**
  String get crimsonScalesSpoilers;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'What is the password for unlocking this envelope?'**
  String get enterPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @vanquisherUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Vanquisher unlocked'**
  String get vanquisherUnlocked;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @useInterFont.
  ///
  /// In en, this message translates to:
  /// **'Use Inter Font'**
  String get useInterFont;

  /// No description provided for @useInterFontDescription.
  ///
  /// In en, this message translates to:
  /// **'Replace stylized fonts with Inter to improve readability'**
  String get useInterFontDescription;

  /// No description provided for @showRetiredCharacters.
  ///
  /// In en, this message translates to:
  /// **'Show Retired Characters'**
  String get showRetiredCharacters;

  /// No description provided for @showRetiredCharactersDescription.
  ///
  /// In en, this message translates to:
  /// **'Toggle visibility of retired characters in the Characters tab to reduce clutter'**
  String get showRetiredCharactersDescription;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Backup your current characters'**
  String get backupDescription;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore your characters from a backup file'**
  String get restoreDescription;

  /// No description provided for @backupFileWarning.
  ///
  /// In en, this message translates to:
  /// **'If another backup file already exists in the Downloads folder with the same name, it will be overwritten'**
  String get backupFileWarning;

  /// No description provided for @filename.
  ///
  /// In en, this message translates to:
  /// **'Filename'**
  String get filename;

  /// No description provided for @savedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String savedTo(String path);

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create backup. Please try again.'**
  String get backupError;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup file will overwrite any current characters. Do you wish to continue?'**
  String get restoreWarning;

  /// No description provided for @errorDuringRestore.
  ///
  /// In en, this message translates to:
  /// **'Error During Restore Operation'**
  String get errorDuringRestore;

  /// No description provided for @restoreErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'There was an error during the restoration process. Your existing data was saved and your backup hasn\'t been modified. Please contact the developer (through the Settings menu) with your existing backup file and this information:\n\n{error}'**
  String restoreErrorMessage(String error);

  /// No description provided for @createAll.
  ///
  /// In en, this message translates to:
  /// **'Create All'**
  String get createAll;

  /// No description provided for @gloomhaven.
  ///
  /// In en, this message translates to:
  /// **'Gloomhaven'**
  String get gloomhaven;

  /// No description provided for @frosthaven.
  ///
  /// In en, this message translates to:
  /// **'Frosthaven'**
  String get frosthaven;

  /// No description provided for @crimsonScales.
  ///
  /// In en, this message translates to:
  /// **'Crimson Scales'**
  String get crimsonScales;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @andVariants.
  ///
  /// In en, this message translates to:
  /// **'& variants'**
  String get andVariants;

  /// No description provided for @createCharacterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create {article} character using the button below, or restore a backup from the Settings menu'**
  String createCharacterPrompt(String article);

  /// No description provided for @articleA.
  ///
  /// In en, this message translates to:
  /// **'a'**
  String get articleA;

  /// No description provided for @articleYourFirst.
  ///
  /// In en, this message translates to:
  /// **'your first'**
  String get articleYourFirst;

  /// No description provided for @class_.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get class_;

  /// No description provided for @classWithVariant.
  ///
  /// In en, this message translates to:
  /// **'Class ({variant})'**
  String classWithVariant(String variant);

  /// No description provided for @startingLevel.
  ///
  /// In en, this message translates to:
  /// **'Starting level'**
  String get startingLevel;

  /// No description provided for @prosperityLevel.
  ///
  /// In en, this message translates to:
  /// **'Prosperity level'**
  String get prosperityLevel;

  /// No description provided for @pleaseSelectClass.
  ///
  /// In en, this message translates to:
  /// **'Please select a Class'**
  String get pleaseSelectClass;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
