# Release History

Reverse-chronological log of production releases with commit references.

## v4.6.1 — Blank-Screen Crash Fix

- **Tag:** `v4.6.1`
- **Commit:** `0b1c120` — "Prepare v4.6.1 release: blank-screen launch crash fix"
- **Date:** 2026-07-12
- Fixed a launch crash that could show a blank grey screen (no app bar) after updating. `EnhancementCalculatorModel` read the persisted enhancement selection with `EnhancementData.enhancements[index]` without bounds-checking; the enhancement list shrank across versions (now 40 items), so an index saved by an older build could exceed the list and throw a `RangeError` during provider construction — which, because the provider is built above the app's `Scaffold`, surfaced as a whole-screen crash. Selection is now read through a bounds-checked `_enhancementFromPrefs()` helper used by both the field initializer and `reloadFromPrefs()`
- Added on-screen crash diagnostics (the app previously had none): `main()` now wraps startup in `runZonedGuarded`, installs an `ErrorWidget.builder` and a guarded `SharedPrefs().init()`, and the `MultiProvider` was extracted into a new `GloomhavenApp` root widget so build-phase / provider-construction exceptions render the new `DiagnosticErrorView` (a dependency-free, screenshot-able error screen) instead of a blank grey rectangle
- iOS App Store fixes (internal): replaced `file_picker` with `file_selector` and added the missing privacy purpose strings so the build passes App Store validation — v4.6.0 was rejected on upload, so v4.6.1 is the first build that both uploads cleanly and fixes the crash. Backup export is now share-sheet only (the device "Save" button was removed), which also drops the camera/photo/location privacy requirements
- Database schema unchanged (still v20)
- Regression tests added under "Persisted enhancement index resilience" in `test/viewmodels/enhancement_calculator_model_test.dart`

## v4.6.0 — Jaws of the Lion Game Mode

- **Tag:** `v4.6.0`
- **Commit:** `e36f1bd` — "Prepare v4.6.0 release: Jaws of the Lion game mode and Resources toggle"
- **Date:** 2026-06-24
- Jaws of the Lion game mode in character creation: locks characters to level 1 (fixed 30 starting gold), hides personal quests / prosperity / resources, and excludes the retirement mechanic (hidden in creation + on the sheet, excluded from `maximumPerks`)
- Game mode is authoritative, not class: persisted via `IsJawsOfTheLion`. A JotL class (e.g. Demolitionist) created under GH/GH2e/FH is a normal character of that mode. JotL is excluded from the enhancement calculator
- Non-interactive italic "Jaws of the Lion" label added to the character header for JotL characters
- Per-character Resources show/hide toggle (`ShowResources`): defaults on for Frosthaven, off otherwise; hiding never clears stored resource counts. "Add resources" button restyled and centered to match the personal-quest button
- Personal quest selector now pins the active quest in a fixed band above the scrolling list
- Database schema v20: adds `ShowResources` and `IsJawsOfTheLion` columns to Characters (single append-only migration; existing rows default to shown / not-JotL). Backup/restore patches pre-v20 backups on import
- Fixed a ListTile ink-splash assertion in `CollapsibleSectionCard` (also unblocked 57 widget tests)
- Replaced the unmaintained `device_region` plugin with the built-in device locale for region detection
- Adopted Swift Package Manager for iOS; fully removed CocoaPods integration (Podfile, build phases, xcconfig includes, workspace ref)
- Internal: enhancement calculator screen split into thematic component files, `InfoDialog` refactored to a data-driven category resolver, animated element configs extracted, character XP/gold writes debounced, dependency upgrades, and a large test backfill (test count ~954 → 1045)

## v4.5.3 — Hand Size Display

- **Commit:** `efa29ff` — "Prepare v4.5.3 release: hand size display and FAQ errata"
- **Date:** 2026-02-24
- Hand size icon added to character stats section (shows class hand size with variant support)
- Frosthaven FAQ errata: corrected Scenario 67 to Scenario 65 in personal quest 12
- Strikethrough text support added to game text parser (`~~text~~` syntax)
- Improved stats row layout with responsive scaling (Expanded + FittedBox)
- New solid pocket icon for pocket items display
- Level badge font updated to PirataOne for consistency
- Dependency bumps: uuid ^4.5.3, syncfusion_flutter_sliders ^32.2.7

## v4.5.2 — All Personal Quests

- **Commit:** `9c7dbd2` — "Prepare v4.5.2 release: all personal quest editions"
- Added Gloomhaven 2nd Edition personal quests (22 quests, cards 01-22 / assets 537-558)
- Added Crimson Scales personal quests (28 quests)
- Added Trail of Ashes personal quests (8 quests)
- All 5 editions now included: 105 quests total (24 GH + 22 GH2E + 23 FH + 28 CS + 8 TOA)
- New `PersonalQuestEdition` enum with edition filter chips in quest selector
- Requirement details bottom sheet for quests with supplemental rules text
- Checklist requirements with bitmask-based progress tracking
- Locked class names in class selector now show blurred text instead of "???" with animated reveal
- Doc comments on all design constants for IDE hover tooltips
- Quest display name separator changed from " - " to ": " (e.g., "510: Seeker of Xorn")
- Neutral `onSurface` colored class icons in personal quest selector
- Verified and corrected Crimson Scales and Trail of Ashes quest descriptions

## v4.5.1 — Frosthaven Personal Quests

- **Commit:** `547ccb6` — "Prepare v4.5.1 release: Frosthaven personal quests"
- **Android:** 2026-02-16 (Google Play)
- **iOS:** 2026-02-19 (App Store Connect)
- Added 23 Frosthaven personal quests to the personal quest selector

## v4.5.0 — Personal Quests

- **Tag:** `v4.5.0`
- **Commit:** `129054f` — "Merge dev into master for release 4.5.0"
- **Android:** 2026-02-14
- Personal quest system: assign, track progress, retire characters
- Edition filter chips in personal quest selector
- Card-flip animation on app bar title during page transitions
- Resource/XP/gold values capped at 999
- Minimum backup version enforcement (DB v8 / app 4.2.0)

## v4.4.0 — Backup Improvements & First-Launch Dialog

- **Tag:** `v4.4.0`
- **Commit:** `7ab9627` — "Adjust text positioning in level and pocket item icons"
- **Android:** 2026-02-06
- SharedPreferences included in database backup/restore
- Backup file format changed from .txt to .json
- Save and Share options in backup dialog
- First-launch dialog for new users
- Variant popup menu refinements

## v4.3.3

- **Commit:** `4d3d6a2` — "Ready for release 4.3.3"
- **Android:** 2026-02-01
- No tag (superseded by v4.4.0 development)

## v4.3.2 — Alchemancer Class

- **Tag:** `v4.3.2`
- **Commit:** `6dc1a70` — "Update changelog for v4.3.2 release"
- **Android:** 2026-01-26
- Added Alchemancer class
- Moved Android INTERNET permission to debug manifest

## v4.3.1 — GH2E Enhancement Calculator

- **Tag:** `v4.3.1`
- **Commit:** `aa82326` — "Increase app version to 4.3.1"
- **Android:** 2026-01-17
- Gloomhaven 2e enhancement calculator mode
- Moved scenario 114 / building 44 settings to enhancement calc screen
- Device info included in support emails
- Icon fixes (consume perk, Satha, spent/spent_light)

## v4.3.0 — Mercenary Packs & Buy Me a Coffee

- **Tag:** `v4.3.0`
- **Commit:** `d147a24` — "Merge pull request #30 from Garrison88/dev"
- **Android:** 2026-01-11
- Mercenary pack classes
- Buy Me a Coffee link
- Changelog and License links in Settings
- Game text parser implementation
- Major theme refactoring
- GH2E classes: Bladeswarm, Sawbones, Doomstalker, Elementalist, Wildfury, Plagueherald, Berserker, Soothsinger, Sunkeeper, Quartermaster, Soultether, Nightshroud

## v4.2.2 — GH2E Character Sheets

- **Tag:** `v4.2.2`
- **Commit:** `c3934a1` — "Release ready. Update to version 4.2.2, increase database schema to 13, minor fixes"
- **Android:** 2025-10-07
- Gloomhaven 2e variant support (Brute/Bruiser etc.)
- Dome, Skitterclaw, and CORE classes
- Cragheart and Mindthief classes
- Silent Knife class
- Database schema v13

## v4.2.1

- **Commit:** `499a81a` — "Merge pull request #8 from Garrison88/pre-release-testing-for-4.2.1"
- **Android:** 2025-06-22

## v4.2.0

- **Commit:** `c57b409` — "Small UI changes. Ready for release"
- **Android:** 2024-06-08

## v4.1.0

- **Commit:** `0d4a8ac` — "final commit of files included in release 4.1.0"
- **Android:** 2023-09-11

## v4.0.0

- **Commit:** `d297c90` — "final commit before release for version 4.0.0"
- **Android:** 2023-03-08

## v3.6.0 — Backup/Restore & Crimson Scales

- **Commit:** `f80d501` — "ready for release of 3.6.0"
- **Android:** 2021-09-21
- Backup/restore features
- Crimson Scales classes
- Updated icons

## v3.1.0

- **Commit:** `19270f4` — "version 3.1.0 tested and deployed to Android and iiOS"
- **Android & iOS:** 2020-07-19

## v1.0.0 — First Release

- **Commit:** `dcdb169` — "release build. first release on Google Play Store"
- **Android:** 2019-01-21
- Enhancement cost calculator
