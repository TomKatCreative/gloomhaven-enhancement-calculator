import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/utils/rich_text_builder.dart';

/// Centralized string content for the app.
///
/// This class stores all UI text as markdown-formatted strings, which are then
/// parsed into RichText using [RichTextBuilder]. This separates content from
/// presentation and makes the strings easier to read, maintain, and test.
class Strings {
  // ============================================================================
  // STATIC CONTENT
  // ============================================================================

  static const String devWebsiteUrl = 'https://www.tomkatcreative.com/contact';

  // ============================================================================
  // GENERAL INFO
  // ============================================================================

  static const String generalInfoTitle = 'Enhancements';

  static String _generalInfoContent({required GameEdition edition}) {
    final isOriginalGH = edition == GameEdition.gloomhaven;
    final achievement = isOriginalGH
        ? '**The Power of Enhancement global achievement**'
        : edition == GameEdition.gloomhaven2e
        ? '**The Power of Enhancement**'
        : '**The Enhancer (Building 44)**';

    final earnedOrBuilt = edition == GameEdition.frosthaven
        ? 'built'
        : 'earned';

    final prosperityLimit = isOriginalGH
        ? 'Players can only enhance a number of cards **less than or equal to** the Prosperity level of Gloomhaven. '
        : '';

    final pipInfo = isOriginalGH
        ? ''
        : '''

 · A pip_square symbol can hold a pip_plus_one sticker. If the action is MOVE and is not a summon ability, it can hold either a pip_plus_one sticker or a JUMP sticker.
 · A pip_circle symbol can hold anything a pip_square can hold, or an Element sticker.
 · A pip_diamond symbol can hold anything a pip_circle can hold, or a negative condition sticker.
 · A pip_diamond_plus symbol can hold anything a pip_circle can hold, or a positive condition sticker.
 · A pip_hex symbol can only hold a Hex sticker.
''';

    final trapInfo = isOriginalGH
        ? ''
        : '''

Some enhancements do not fall neatly into the categories on the cost chart. When determining their base cost, treat damage traps as ATTACK+1 enhancements (50g), healing traps as HEAL+1 enhancements (30g), and the movement of tokens and tiles as MOVE+1 enhancements (30g).''';

    return '''Congratulations! Now that your company has $earnedOrBuilt $achievement, its members can purchase enhancements to permanently augment their class's cards. This is done by paying the associated cost (determined by card level, number of previous enhancements, type of enhancement, etc.) and adding a sticker to the card. $prosperityLimit
Only abilities with a small translucent icon beside them can be enhanced, and only one enhancement per icon can be added.$pipInfo

Once an enhancement is placed, **it persists through subsequent playthroughs** with that class (unless you have chosen to use the 'Temporary Enhancement' variant).

A **main** ability is an ability that is written in larger font, whereas a **non-main** ability is written in a smaller font below a **main** ability. A summon's stats can **only** be augmented with pip_plus_one enhancements.$trapInfo''';
  }

  static RichText generalInfoBody(
    BuildContext context, {
    required GameEdition edition,
    required bool darkMode,
  }) {
    return RichTextBuilder.build(
      context,
      _generalInfoContent(edition: edition),
      darkMode,
    );
  }

  // ============================================================================
  // TEMPORARY ENHANCEMENT
  // ============================================================================

  static const String temporaryEnhancement = "'Temporary Enhancement' Variant";

  static const String _temporaryEnhancementContent =
      "With this variant, enhancement stickers are removed when a character retires. This "
      "can be facilitated by affixing the stickers to card sleeves, instead of directly to "
      "the ability cards, or by applying reusable stickers (which are sold separately). "
      "Temporary enhancements have a reduced cost: First, calculate the normal enhancement "
      "cost, including any discounts. Next, if the action has at least one previous "
      "enhancement, reduce the cost by 20 gold. Finally, reduce the cost by 20 percent "
      "(rounded up).";

  static RichText temporaryEnhancementInfoBody(
    BuildContext context,
    bool darkMode,
  ) {
    return RichTextBuilder.build(
      context,
      _temporaryEnhancementContent,
      darkMode,
    );
  }

  // ============================================================================
  // SCENARIO 114 REWARD (PARTY BOON)
  // ============================================================================

  static const String scenario114RewardTitle = "Scenario 114 Reward";

  static const String _scenario114RewardContent =
      "After completing Scenario 114 (from the Forgotten Circles expansion), your party "
      "unlocks a **Party Boon** that reduces the card level fee for enhancements by 5 "
      "gold per card level. This discount stacks with other discounts and applies to "
      "all characters in the campaign.";

  static RichText scenario114RewardInfoBody(
    BuildContext context,
    bool darkMode,
  ) {
    return RichTextBuilder.build(context, _scenario114RewardContent, darkMode);
  }

  // ============================================================================
  // BUILDING 44 (ENHANCER)
  // ============================================================================

  static const String building44Title = "Building 44";

  static const String _building44Content =
      "Building 44 is **The Enhancer** in Frosthaven. Once built, it allows your party "
      "to purchase enhancements. The building can be upgraded to provide additional "
      "discounts:\n\n"
      "**Level 1:** Buy enhancements\n"
      "**Level 2:** Reduce all enhancement costs by 10 gold\n"
      "**Level 3:** Reduce card level penalties by 10 gold per level\n"
      "**Level 4:** Reduce repeat enhancement penalties by 25 gold per enhancement";

  static RichText building44InfoBody(BuildContext context, bool darkMode) {
    return RichTextBuilder.build(context, _building44Content, darkMode);
  }

  // ============================================================================
  // HAIL'S DISCOUNT
  // ============================================================================

  static const String hailsDiscountTitle = "Hail's Discount";

  static const String _hailsDiscountContent =
      "Hail from the Mercenary Pack has a Perk that reduces the cost of the party's "
      "Enhancements by 5 gold.";

  static RichText hailsDiscountInfoBody(BuildContext context, bool darkMode) {
    return RichTextBuilder.build(context, _hailsDiscountContent, darkMode);
  }

  // ============================================================================
  // CARD LEVEL
  // ============================================================================

  static const String cardLevelInfoTitle = "Card Level Fee";

  static String _cardLevelContent({
    required GameEdition edition,
    required bool partyBoon,
    required bool enhancerLvl3,
  }) {
    String baseContent =
        "25 gold is added to the cost of an enhancement for each card level beyond 1 or x.";

    // Add Party Boon info for GH/GH2E if enabled
    if (edition.supportsPartyBoon && partyBoon) {
      baseContent +=
          "\n\nWith the **Party Boon** unlocked, this fee is reduced by 5 gold per card level.";
    }

    // Add Enhancer Lvl 3 info for FH if enabled
    if (edition.hasEnhancerLevels && enhancerLvl3) {
      baseContent +=
          "\n\nWith **Enhancer level 3** unlocked, this fee is reduced by 10 gold per card level.";
    }

    return baseContent;
  }

  static RichText cardLevelInfoBody(
    BuildContext context,
    bool darkMode, {
    required GameEdition edition,
    required bool partyBoon,
    required bool enhancerLvl3,
  }) {
    return RichTextBuilder.build(
      context,
      _cardLevelContent(
        edition: edition,
        partyBoon: partyBoon,
        enhancerLvl3: enhancerLvl3,
      ),
      darkMode,
    );
  }

  // ============================================================================
  // PREVIOUS ENHANCEMENTS
  // ============================================================================

  static const String previousEnhancementsInfoTitle =
      "Previous Enhancements Fee";

  static String _previousEnhancementsContent({
    required GameEdition edition,
    required bool enhancerLvl4,
  }) {
    String baseContent =
        "75 gold is added to the cost of an enhancement for each previous enhancement on the "
        "**same action.** An action is defined as the top or bottom half of a card. This fee "
        "**does not** apply to an enhancement on a top action where a bottom action "
        "enhancement already exists, or vice versa.";

    // Add Enhancer Lvl 4 info for FH if enabled
    if (edition.hasEnhancerLevels && enhancerLvl4) {
      baseContent +=
          "\n\nWith **Enhancer level 4** unlocked, this fee is reduced by 25 gold per previous enhancement.";
    }

    // Add Temporary Enhancement discount info (always shown - not a spoiler)
    baseContent +=
        "\n\nWith the **Temporary Enhancement** variant, if the action has at least one previous enhancement, the cost is reduced by an additional 20 gold.";

    return baseContent;
  }

  static RichText previousEnhancementsInfoBody(
    BuildContext context,
    bool darkMode, {
    required GameEdition edition,
    required bool enhancerLvl4,
  }) {
    return RichTextBuilder.build(
      context,
      _previousEnhancementsContent(
        edition: edition,
        enhancerLvl4: enhancerLvl4,
      ),
      darkMode,
    );
  }

  // ============================================================================
  // PLUS ONE CHARACTER
  // ============================================================================

  static String _plusOneCharacterContent({required GameEdition edition}) {
    // In GH, multi-target applies to all (including Target); in GH2E/FH it never applies to Target
    final targetMultiplier = edition.multiTargetAppliesToAll
        ? 'always'
        : 'never';
    return "This enhancement can be placed on any ability line with a **numerical value.** "
        "That value is increased by 1. Increasing a Target by 1 is **$targetMultiplier** "
        "subject to the multiple targets multiplier.";
  }

  static RichText plusOneCharacterInfoBody(
    BuildContext context,
    GameEdition edition,
    bool darkMode,
  ) {
    return RichTextBuilder.build(
      context,
      _plusOneCharacterContent(edition: edition),
      darkMode,
    );
  }

  // ============================================================================
  // PLUS ONE SUMMON
  // ============================================================================

  static String _plusOneSummonContent({required GameEdition edition}) {
    String modifierInfo = '';

    if (edition == GameEdition.gloomhaven2e) {
      // GH2E: Summons excluded from lost discount (rule says "not a summon action")
      modifierInfo =
          ' Summon stat enhancements are **never** subject to the lost action discount.';
    } else if (edition.hasPersistentModifier) {
      // FH: Summons excluded from persistent multiplier only (lost discount can apply)
      modifierInfo =
          ' Summon stat enhancements are **never** subject to the persistent icon multiplier.';
    }

    return "This enhancement can be placed on any summon ability with a **numerical value.** "
        "That value is increased by 1.$modifierInfo";
  }

  static RichText plusOneSummonInfoBody(
    BuildContext context,
    GameEdition edition,
    bool darkMode,
  ) {
    return RichTextBuilder.build(
      context,
      _plusOneSummonContent(edition: edition),
      darkMode,
    );
  }

  // ============================================================================
  // NEGATIVE EFFECTS
  // ============================================================================

  static const String _negEffectContent =
      "These enhancements can be placed on any **main** ability line that targets enemies. "
      "The specified condition is applied to all targets of that ability (unless they are "
      "immune). Curse can be added multiple times to the same ability line. Summon abilities "
      "**cannot** be enhanced with effects.";

  static RichText negEffectInfoBody(BuildContext context, bool darkMode) {
    return RichTextBuilder.build(context, _negEffectContent, darkMode);
  }

  // ============================================================================
  // POSITIVE EFFECTS
  // ============================================================================

  static const String _posEffectContent =
      "These enhancements can be placed on any **main** ability line that targets allies "
      "or yourself. The specified condition is applied to all targets of that ability. "
      "Bless can be added multiple times to the same ability line. Summon abilities "
      "**cannot** be enhanced with effects.";

  static RichText posEffectInfoBody(BuildContext context, bool darkMode) {
    return RichTextBuilder.build(context, _posEffectContent, darkMode);
  }

  // ============================================================================
  // JUMP
  // ============================================================================

  static const String _jumpContent =
      "This enhancement can be placed on any move ability line. The movement is now "
      "considered a Jump. A summon's Move **cannot** be enhanced with Jump.";

  static RichText jumpInfoBody(BuildContext context, bool darkMode) {
    return RichTextBuilder.build(context, _jumpContent, darkMode);
  }

  // ============================================================================
  // SPECIFIC ELEMENT
  // ============================================================================

  static String _specificElementContent({required GameEdition edition}) {
    // In GH, multi-target applies to elements; in GH2E/FH it doesn't
    final multiplierInfo = edition.multiTargetAppliesToAll
        ? ''
        : ' Element enhancements are **never** subject to the multiple targets multiplier.';

    return "These enhancements can be placed on any **main** ability line. The specific "
        "element is created when the ability is used.$multiplierInfo";
  }

  static RichText specificElementInfoBody(
    BuildContext context,
    GameEdition edition,
    bool darkMode,
  ) {
    return RichTextBuilder.build(
      context,
      _specificElementContent(edition: edition),
      darkMode,
    );
  }

  // ============================================================================
  // ANY ELEMENT
  // ============================================================================

  static String _anyElementContent({required GameEdition edition}) {
    // In GH, multi-target applies to elements; in GH2E/FH it doesn't
    final multiplierInfo = edition.multiTargetAppliesToAll
        ? ''
        : ' Element enhancements are **never** subject to the multiple targets multiplier.';

    return "This enhancement can be placed on any **main** ability line. The player chooses "
        "the element that is created when the ability is used.$multiplierInfo";
  }

  static RichText anyElementInfoBody(
    BuildContext context,
    GameEdition edition,
    bool darkMode,
  ) {
    return RichTextBuilder.build(
      context,
      _anyElementContent(edition: edition),
      darkMode,
    );
  }

  // ============================================================================
  // HEX
  // ============================================================================

  static const String _hexContent =
      "This enhancement can be placed to increase the graphical depiction of an "
      "**area attack.** The new Hex becomes an additional target of the attack. Adding "
      "a Hex is **never** subject to the multiple targets multiplier.";

  static RichText hexInfoBody(BuildContext context, bool darkMode) {
    return RichTextBuilder.build(context, _hexContent, darkMode);
  }

  // ============================================================================
  // MULTIPLE TARGETS
  // ============================================================================

  static const String multipleTargetsInfoTitle = "Multiple Targets Multiplier";

  static String _multipleTargetsContent({
    required GameEdition edition,
    required bool enhancerLvl2,
  }) {
    final String editionRules;
    if (edition.multiTargetAppliesToAll) {
      // Original Gloomhaven
      editionRules =
          "This will **always** apply to adding TARGET_CIRCLE+1, and it will **never** apply to adding an area-of-effect hex.";
    } else {
      // GH2E and Frosthaven
      final enhancerInfo = (edition.hasEnhancerLevels && enhancerLvl2)
          ? '\nThis multiplier is applied before the discount applied by upgrading the Enhancer (Building 44) to lvl 2.\nFor example, with the Enhancer lvl 2 upgrade, adding WOUND to an action that has multiple targets will cost 140g, calculated as (75x2)-10.'
          : '';
      editionRules =
          "This will **never** apply to adding TARGET_CIRCLE+1, enhancing an ability with an Element, or adding an area-of-effect hex.$enhancerInfo";
    }

    return "If an ability targets multiple enemies or allies, the enhancement base cost is "
        "**doubled**. This includes abilities that target 'All adjacent enemies' or "
        "'All allies within RANGE 3', for example. $editionRules";
  }

  static RichText multipleTargetsInfoBody(
    BuildContext context, {
    required GameEdition edition,
    required bool enhancerLvl2,
    required bool darkMode,
  }) {
    return RichTextBuilder.build(
      context,
      _multipleTargetsContent(edition: edition, enhancerLvl2: enhancerLvl2),
      darkMode,
    );
  }

  // ============================================================================
  // LOST NON-PERSISTENT
  // ============================================================================

  static String lostNonPersistentInfoTitle({required GameEdition edition}) {
    // GH2E doesn't have persistent modifier, so title is just "Lost"
    return edition.hasPersistentModifier ? "Lost & Non-Persistent" : "Lost";
  }

  static String _lostNonPersistentContent({required GameEdition edition}) {
    if (edition.hasPersistentModifier) {
      // Frosthaven
      return "If the action has a Lost icon, but no Persistent icon, halve the base cost.";
    } else {
      // GH2E
      return "If the action has a Lost icon **and is not a summon action**, halve the base cost.";
    }
  }

  static RichText lostNonPersistentInfoBody(
    BuildContext context,
    GameEdition edition,
    bool darkMode,
  ) {
    return RichTextBuilder.build(
      context,
      _lostNonPersistentContent(edition: edition),
      darkMode,
    );
  }

  // ============================================================================
  // PERSISTENT
  // ============================================================================

  static const String persistentInfoTitle = "Persistent";

  static const String _persistentContent =
      "If the action has a Persistent icon, whether or not there is a Lost icon, triple "
      "the base cost. This **does not** apply to summon stat enhancements.";

  static RichText persistentInfoBody(BuildContext context, bool darkMode) {
    return RichTextBuilder.build(context, _persistentContent, darkMode);
  }

  // ============================================================================
  // NEW CHARACTER
  // ============================================================================

  static const String newCharacterInfoTitle = "New Character";

  static String _newCharacterContent({required GameEdition edition}) {
    switch (edition) {
      case GameEdition.gloomhaven:
        return "When starting a new character in Gloomhaven, you can choose to immediately "
            "level up to any level less than or equal to the current Prosperity Level of the "
            "city, gaining the benefits for each level in sequence.\n\n"
            "You are also alloted an amount of gold equal to **15x(L+1)**, where 'L' is your "
            "character's starting level.\n\n"
            "For example, if the city is at Prosperity Level 3, you could start a character at "
            "level 1, 2, or 3, and would be alloted 30, 45, or 60 gold, respectively.";
      case GameEdition.gloomhaven2e:
        return "When starting a new character in Gloomhaven 2E, they always start "
            "at level 1. They may immediately level up (even multiple times) as long as their "
            "level does not exceed half the current Prosperity Level (rounded up).\n\n"
            "You are alloted an amount of gold equal to **10xP+15**, where 'P' is the current "
            "Prosperity Level. This gold must be spent immediately on items.\n\n"
            "For example, if the city is at Prosperity Level 4, you could level up to level 2, "
            "and would be alloted 55 gold.";
      case GameEdition.frosthaven:
        return "When starting a new character in Frosthaven, you can choose to immediately "
            "level up to any level less than or equal to the current Prosperity Level of the "
            "city divided by 2 (rounded up), gaining the benefits for each level in sequence.\n\n"
            "You are also alloted an amount of gold equal to **10xP+20**, where 'P' is the "
            "current Prosperity Level.\n\n"
            "For example, if the city is at Prosperity Level 3, you could start a character at "
            "level 1 or 2, and would be alloted 50 gold. This gold must be spent immediately "
            "on items in the available purchasable supply, and any unspent gold is forfeited.";
    }
  }

  static RichText newCharacterInfoBody(
    BuildContext context, {
    required GameEdition edition,
    required bool darkMode,
  }) {
    return RichTextBuilder.build(
      context,
      _newCharacterContent(edition: edition),
      darkMode,
    );
  }
}
