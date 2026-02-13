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

  /// No description provided for @switchAction.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchAction;

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
  /// **'Support & feedback'**
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

  /// No description provided for @retirements.
  ///
  /// In en, this message translates to:
  /// **'Retirements'**
  String get retirements;

  /// No description provided for @pocketItemsAllowed.
  ///
  /// In en, this message translates to:
  /// **'{count} pocket item{count, plural, =1{} other{s}} allowed'**
  String pocketItemsAllowed(int count);

  /// No description provided for @battleGoals.
  ///
  /// In en, this message translates to:
  /// **'Battle Goals'**
  String get battleGoals;

  /// No description provided for @cardLevel.
  ///
  /// In en, this message translates to:
  /// **'Card level'**
  String get cardLevel;

  /// No description provided for @previousEnhancements.
  ///
  /// In en, this message translates to:
  /// **'Previous enhancements'**
  String get previousEnhancements;

  /// No description provided for @enhancementType.
  ///
  /// In en, this message translates to:
  /// **'Enhancement type'**
  String get enhancementType;

  /// No description provided for @actionDetails.
  ///
  /// In en, this message translates to:
  /// **'Enhancement'**
  String get actionDetails;

  /// No description provided for @cardDetails.
  ///
  /// In en, this message translates to:
  /// **'Card details'**
  String get cardDetails;

  /// No description provided for @discounts.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get discounts;

  /// No description provided for @enhancementCalculator.
  ///
  /// In en, this message translates to:
  /// **'Enhancement calculator'**
  String get enhancementCalculator;

  /// No description provided for @enhancementGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Enhancement guidelines'**
  String get enhancementGuidelines;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Select type...'**
  String get type;

  /// No description provided for @multipleTargets.
  ///
  /// In en, this message translates to:
  /// **'Multiple targets'**
  String get multipleTargets;

  /// No description provided for @generalGuidelines.
  ///
  /// In en, this message translates to:
  /// **'General guidelines'**
  String get generalGuidelines;

  /// No description provided for @scenario114Reward.
  ///
  /// In en, this message translates to:
  /// **'Scenario 114 reward'**
  String get scenario114Reward;

  /// No description provided for @forgottenCirclesSpoilers.
  ///
  /// In en, this message translates to:
  /// **'Forgotten Circles spoilers'**
  String get forgottenCirclesSpoilers;

  /// No description provided for @temporaryEnhancement.
  ///
  /// In en, this message translates to:
  /// **'Temporary enhancements'**
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
  /// **'Hail\'s discount'**
  String get hailsDiscount;

  /// No description provided for @lossNonPersistent.
  ///
  /// In en, this message translates to:
  /// **'Lost & non-persistent'**
  String get lossNonPersistent;

  /// No description provided for @persistent.
  ///
  /// In en, this message translates to:
  /// **'Persistent'**
  String get persistent;

  /// No description provided for @eligibleFor.
  ///
  /// In en, this message translates to:
  /// **'Eligible for'**
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
  /// **'LOCAL BACKUP & RESTORE'**
  String get backupAndRestore;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'TESTING'**
  String get testing;

  /// No description provided for @customClasses.
  ///
  /// In en, this message translates to:
  /// **'Custom classes'**
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
  /// **'Use Inter font'**
  String get useInterFont;

  /// No description provided for @useInterFontDescription.
  ///
  /// In en, this message translates to:
  /// **'Replace stylized fonts with Inter to improve readability'**
  String get useInterFontDescription;

  /// No description provided for @showRetiredCharacters.
  ///
  /// In en, this message translates to:
  /// **'Show retired characters'**
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
  /// **'Backup your current characters to your device'**
  String get backupDescription;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore your characters from a backup file on your device'**
  String get restoreDescription;

  /// No description provided for @filename.
  ///
  /// In en, this message translates to:
  /// **'Filename'**
  String get filename;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved {filename}'**
  String saved(String filename);

  /// No description provided for @filenameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a filename'**
  String get filenameRequired;

  /// No description provided for @backupIncludes.
  ///
  /// In en, this message translates to:
  /// **'Your backup will include all characters, perks, masteries, and app settings (theme, calculator state, class unlocks).'**
  String get backupIncludes;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create backup. Please try again.'**
  String get backupError;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup file will overwrite all current characters and app settings (theme, calculator state, class unlocks). Do you wish to continue?'**
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
  /// **'Create all'**
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

  /// No description provided for @levelExceedsProsperity.
  ///
  /// In en, this message translates to:
  /// **'Max starting level at this prosperity is {maxLevel}'**
  String levelExceedsProsperity(int maxLevel);

  /// No description provided for @prosperityLevel.
  ///
  /// In en, this message translates to:
  /// **'Prosperity'**
  String get prosperityLevel;

  /// No description provided for @createCharacter.
  ///
  /// In en, this message translates to:
  /// **'Create character'**
  String get createCharacter;

  /// No description provided for @gameEdition.
  ///
  /// In en, this message translates to:
  /// **'Game edition'**
  String get gameEdition;

  /// No description provided for @selectClass.
  ///
  /// In en, this message translates to:
  /// **'Select class...'**
  String get selectClass;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes...'**
  String get addNotes;

  /// No description provided for @personalQuest.
  ///
  /// In en, this message translates to:
  /// **'Personal Quest'**
  String get personalQuest;

  /// No description provided for @selectPersonalQuest.
  ///
  /// In en, this message translates to:
  /// **'Select personal quest...'**
  String get selectPersonalQuest;

  /// No description provided for @selectAPersonalQuest.
  ///
  /// In en, this message translates to:
  /// **'Select a Personal Quest'**
  String get selectAPersonalQuest;

  /// No description provided for @changePersonalQuest.
  ///
  /// In en, this message translates to:
  /// **'Change Personal Quest?'**
  String get changePersonalQuest;

  /// No description provided for @changePersonalQuestBody.
  ///
  /// In en, this message translates to:
  /// **'This will replace your current quest and reset all progress.'**
  String get changePersonalQuestBody;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon...'**
  String get comingSoon;

  /// No description provided for @noPersonalQuest.
  ///
  /// In en, this message translates to:
  /// **'No personal quest selected'**
  String get noPersonalQuest;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @progressOf.
  ///
  /// In en, this message translates to:
  /// **'{current}/{target}'**
  String progressOf(int current, int target);

  /// No description provided for @personalQuestComplete.
  ///
  /// In en, this message translates to:
  /// **'Personal quest complete!'**
  String get personalQuestComplete;

  /// No description provided for @personalQuestCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'{name} has fulfilled their personal quest and must retire. Before retiring, consider spending gold on enhancements or donations — all gold and items are lost upon retirement. The city gains 1 prosperity.'**
  String personalQuestCompleteBody(String name);

  /// No description provided for @retire.
  ///
  /// In en, this message translates to:
  /// **'Retire'**
  String get retire;

  /// No description provided for @unretire.
  ///
  /// In en, this message translates to:
  /// **'Unretire'**
  String get unretire;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not Yet'**
  String get notYet;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General & Party'**
  String get general;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get stats;

  /// No description provided for @quest.
  ///
  /// In en, this message translates to:
  /// **'Quest'**
  String get quest;

  /// No description provided for @perks.
  ///
  /// In en, this message translates to:
  /// **'Perks'**
  String get perks;

  /// No description provided for @masteries.
  ///
  /// In en, this message translates to:
  /// **'Masteries'**
  String get masteries;

  /// No description provided for @questAndNotes.
  ///
  /// In en, this message translates to:
  /// **'Quest & Notes'**
  String get questAndNotes;

  /// No description provided for @perksAndMasteries.
  ///
  /// In en, this message translates to:
  /// **'Perks & Masteries'**
  String get perksAndMasteries;

  /// No description provided for @town.
  ///
  /// In en, this message translates to:
  /// **'TOWN'**
  String get town;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'CHARACTERS'**
  String get characters;

  /// No description provided for @enhancements.
  ///
  /// In en, this message translates to:
  /// **'ENHANCEMENTS'**
  String get enhancements;

  /// No description provided for @subtract.
  ///
  /// In en, this message translates to:
  /// **'Subtract'**
  String get subtract;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @campaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get campaign;

  /// No description provided for @campaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get campaigns;

  /// No description provided for @party.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get party;

  /// No description provided for @parties.
  ///
  /// In en, this message translates to:
  /// **'Parties'**
  String get parties;

  /// No description provided for @createCampaign.
  ///
  /// In en, this message translates to:
  /// **'Create campaign'**
  String get createCampaign;

  /// No description provided for @createParty.
  ///
  /// In en, this message translates to:
  /// **'Create party'**
  String get createParty;

  /// No description provided for @prosperity.
  ///
  /// In en, this message translates to:
  /// **'Prosperity'**
  String get prosperity;

  /// No description provided for @prosperityLevelN.
  ///
  /// In en, this message translates to:
  /// **'Prosperity {level}'**
  String prosperityLevelN(int level);

  /// No description provided for @reputation.
  ///
  /// In en, this message translates to:
  /// **'Reputation'**
  String get reputation;

  /// No description provided for @noCampaignsYet.
  ///
  /// In en, this message translates to:
  /// **'Create a campaign to track your parties'**
  String get noCampaignsYet;

  /// No description provided for @noPartiesYet.
  ///
  /// In en, this message translates to:
  /// **'Create a party to track reputation and assign characters'**
  String get noPartiesYet;

  /// No description provided for @campaignName.
  ///
  /// In en, this message translates to:
  /// **'Campaign name'**
  String get campaignName;

  /// No description provided for @partyName.
  ///
  /// In en, this message translates to:
  /// **'Party name'**
  String get partyName;

  /// No description provided for @edition.
  ///
  /// In en, this message translates to:
  /// **'Edition'**
  String get edition;

  /// No description provided for @sanctuaryDonations.
  ///
  /// In en, this message translates to:
  /// **'Sanctuary of the Great Oak donations'**
  String get sanctuaryDonations;

  /// No description provided for @startingProsperity.
  ///
  /// In en, this message translates to:
  /// **'Starting prosperity'**
  String get startingProsperity;

  /// No description provided for @startingReputation.
  ///
  /// In en, this message translates to:
  /// **'Starting reputation'**
  String get startingReputation;

  /// No description provided for @deleteCampaign.
  ///
  /// In en, this message translates to:
  /// **'Delete campaign?'**
  String get deleteCampaign;

  /// No description provided for @deleteCampaignBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this campaign and all its parties. Characters will be unlinked but not deleted.'**
  String get deleteCampaignBody;

  /// No description provided for @deleteParty.
  ///
  /// In en, this message translates to:
  /// **'Delete party?'**
  String get deleteParty;

  /// No description provided for @deletePartyBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this party. Characters will be unlinked but not deleted.'**
  String get deletePartyBody;

  /// No description provided for @selectCampaign.
  ///
  /// In en, this message translates to:
  /// **'Select campaign'**
  String get selectCampaign;

  /// No description provided for @selectParty.
  ///
  /// In en, this message translates to:
  /// **'Select party'**
  String get selectParty;

  /// No description provided for @switchParty.
  ///
  /// In en, this message translates to:
  /// **'Switch party'**
  String get switchParty;

  /// No description provided for @renameCampaign.
  ///
  /// In en, this message translates to:
  /// **'Rename campaign'**
  String get renameCampaign;

  /// No description provided for @renameParty.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameParty;

  /// No description provided for @checkmarks.
  ///
  /// In en, this message translates to:
  /// **'checkmarks'**
  String get checkmarks;

  /// No description provided for @openEnvelopeB.
  ///
  /// In en, this message translates to:
  /// **'Open envelope B'**
  String get openEnvelopeB;

  /// No description provided for @noParty.
  ///
  /// In en, this message translates to:
  /// **'No party'**
  String get noParty;

  /// No description provided for @notAssignedToParty.
  ///
  /// In en, this message translates to:
  /// **'Not assigned to a party'**
  String get notAssignedToParty;

  /// No description provided for @assignToParty.
  ///
  /// In en, this message translates to:
  /// **'Assign to a party'**
  String get assignToParty;

  /// No description provided for @createCampaignFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a campaign first to assign a party'**
  String get createCampaignFirst;

  /// No description provided for @scenarioLocation.
  ///
  /// In en, this message translates to:
  /// **'Scenario location'**
  String get scenarioLocation;

  /// No description provided for @partyNotes.
  ///
  /// In en, this message translates to:
  /// **'Party notes'**
  String get partyNotes;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @shopPriceModifier.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopPriceModifier;

  /// No description provided for @addPartyNotes.
  ///
  /// In en, this message translates to:
  /// **'Add party notes...'**
  String get addPartyNotes;
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
