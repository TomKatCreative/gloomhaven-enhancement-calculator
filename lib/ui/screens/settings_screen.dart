import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helpers.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/changelog_screen.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final EnhancementCalculatorModel enhancementCalculatorModel;

  const SettingsScreen({super.key, required this.enhancementCalculatorModel});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final ScrollController scrollController = ScrollController();
  bool isBottom = false;
  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if ((scrollController.offset >=
          scrollController.position.maxScrollExtent)) {
        setState(() {
          isBottom = true;
        });
      } else {
        setState(() {
          isBottom = false;
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  late String downloadPath;

  final Future<PackageInfo> _packageInfoFuture = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: Platform.isAndroid,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).settings,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: ListView(
              children: <Widget>[
                SettingsSection(title: AppLocalizations.of(context).gameplay),
                SwitchListTile(
                  secondary: Icon(
                    SharedPrefs().customClasses
                        ? MdiIcons.testTube
                        : MdiIcons.testTubeOff,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context).customClassesDescription,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  title: Text(AppLocalizations.of(context).customClasses),
                  value: SharedPrefs().customClasses,
                  onChanged: (val) {
                    setState(() {
                      SharedPrefs().customClasses = val;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(
                    AppLocalizations.of(context).enhancementGuidelines,
                  ),
                  trailing: Icon(
                    Icons.open_in_new,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) {
                      return InfoDialog(
                        title: Strings.generalInfoTitle,
                        message: Strings.generalInfoBody(
                          context,
                          edition: SharedPrefs().gameEdition,
                          darkMode:
                              Theme.of(context).brightness == Brightness.dark,
                        ),
                      );
                    },
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.warning_rounded),
                  title: Text(AppLocalizations.of(context).solveEnvelopeX),
                  subtitle: Text(
                    AppLocalizations.of(context).gloomhavenSpoilers,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  value: SharedPrefs().envelopeX,
                  onChanged: (val) {
                    if (!val) {
                      setState(() {
                        SharedPrefs().envelopeX = false;
                      });
                    } else {
                      showDialog<bool>(
                        context: context,
                        builder: (_) {
                          bool envelopeXSolved = false;
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                                  return AlertDialog(
                                    content: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: maxDialogWidth,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            ).enterSolution,
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            autofocus: true,
                                            onChanged: (String val) {
                                              setState(() {
                                                envelopeXSolved =
                                                    val.toLowerCase().trim() ==
                                                    'bladeswarm';
                                              });
                                            },
                                            decoration: InputDecoration(
                                              labelText: AppLocalizations.of(
                                                context,
                                              ).solution,
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          AppLocalizations.of(context).cancel,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        onPressed: envelopeXSolved
                                            ? () {
                                                Navigator.of(context).pop(true);
                                              }
                                            : null,
                                        child: Text(
                                          AppLocalizations.of(context).solve,
                                          style: TextStyle(
                                            color: envelopeXSolved
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).disabledColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                          );
                        },
                      ).then((bool? value) {
                        if (value != null && value) {
                          setState(() {
                            SharedPrefs().envelopeX = val;
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(
                                content: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ThemedSvg(
                                      assetKey: 'Bladeswarm',
                                      width: iconSize,
                                      height: iconSize,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: mediumPadding),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      ).bladeswarmUnlocked,
                                    ),
                                  ],
                                ),
                              ),
                            );
                        }
                      });
                    }
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.warning_rounded),
                  title: Text(AppLocalizations.of(context).unlockEnvelopeV),
                  subtitle: Text(
                    AppLocalizations.of(context).crimsonScalesSpoilers,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  value: SharedPrefs().envelopeV,
                  onChanged: (val) {
                    if (!val) {
                      setState(() {
                        SharedPrefs().envelopeV = false;
                      });
                    } else {
                      showDialog<bool>(
                        context: context,
                        builder: (_) {
                          bool envelopeVSolved = false;
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                                  return AlertDialog(
                                    content: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: maxDialogWidth,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            ).enterPassword,
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            autofocus: true,
                                            onChanged: (String val) {
                                              setState(() {
                                                envelopeVSolved =
                                                    val.toLowerCase().trim() ==
                                                    'ashes';
                                              });
                                            },
                                            decoration: InputDecoration(
                                              labelText: AppLocalizations.of(
                                                context,
                                              ).password,
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          AppLocalizations.of(context).cancel,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        onPressed: envelopeVSolved
                                            ? () {
                                                Navigator.of(context).pop(true);
                                              }
                                            : null,
                                        child: Text(
                                          AppLocalizations.of(context).unlock,
                                          style: TextStyle(
                                            color: envelopeVSolved
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).disabledColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                          );
                        },
                      ).then((bool? value) {
                        if (value != null && value) {
                          setState(() {
                            SharedPrefs().envelopeV = val;
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(
                                content: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ThemedSvg(
                                      assetKey: 'RAGE',
                                      width: iconSize,
                                      height: iconSize,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: mediumPadding),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      ).vanquisherUnlocked,
                                    ),
                                  ],
                                ),
                              ),
                            );
                        }
                      });
                    }
                  },
                ),
                SettingsSection(title: AppLocalizations.of(context).display),
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(
                      context,
                    ).colorScheme.copyWith(outline: Colors.transparent),
                  ),
                  child: SwitchListTile(
                    secondary: Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                    ),
                    title: Text(AppLocalizations.of(context).brightness),
                    subtitle: Text(
                      Theme.of(context).brightness == Brightness.dark
                          ? AppLocalizations.of(context).dark
                          : AppLocalizations.of(context).light,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    activeThumbImage: const AssetImage(
                      'images/elements/elem_dark.png',
                    ),
                    activeThumbColor: const Color(0xff1f272e),
                    inactiveThumbColor: const Color(0xffeda50b),
                    inactiveTrackColor: const Color(
                      0xffeda50b,
                    ).withValues(alpha: 0.75),
                    activeTrackColor: const Color(0xff1f272e),
                    inactiveThumbImage: const AssetImage(
                      'images/elements/elem_light.png',
                    ),
                    value: context.watch<ThemeProvider>().useDarkMode,
                    onChanged: (val) {
                      context.read<ThemeProvider>().updateDarkMode(val);
                    },
                  ),
                ),
                SwitchListTile(
                  secondary: Icon(MdiIcons.formatFont),
                  title: Text(AppLocalizations.of(context).useInterFont),
                  subtitle: Text(
                    AppLocalizations.of(context).useInterFontDescription,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  value: context.watch<ThemeProvider>().useDefaultFonts,
                  onChanged: (val) {
                    context.read<ThemeProvider>().updateDefaultFonts(val);
                  },
                ),
                SwitchListTile(
                  secondary: Icon(
                    context.read<CharactersModel>().showRetired
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                  title: Text(
                    AppLocalizations.of(context).showRetiredCharacters,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(
                      context,
                    ).showRetiredCharactersDescription,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  value: context.read<CharactersModel>().showRetired,
                  onChanged: (val) {
                    setState(() {
                      context.read<CharactersModel>().toggleShowRetired();
                    });
                  },
                ),
                SettingsSection(
                  title: AppLocalizations.of(context).backupAndRestore,
                ),
                ListTile(
                  leading: const Icon(Icons.upload_rounded),
                  title: Text(AppLocalizations.of(context).backup),
                  subtitle: Text(
                    AppLocalizations.of(context).backupDescription,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  onTap: () async {
                    await showDialog<String?>(
                      context: context,
                      builder: (context) {
                        final TextEditingController
                        fileNameController = TextEditingController()
                          ..text =
                              'ghc_backup_${DateFormat('yyyy-MM-dd_HH:mm').format(DateTime.now())}'
                                  .replaceAll(RegExp(':'), '-');
                        return AlertDialog(
                          title: Platform.isAndroid
                              ? const Icon(Icons.warning_rounded)
                              : null,
                          content: Container(
                            constraints: const BoxConstraints(
                              maxWidth: maxDialogWidth,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (Platform.isAndroid) ...[
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).backupFileWarning,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                TextField(
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: AppLocalizations.of(
                                      context,
                                    ).filename,
                                  ),
                                  controller: fileNameController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(
                                        '[\\#|\\<|\\>|\\+|\\\$|\\%|\\!|\\`|\\&|\\*|\\\'|\\||\\}|\\{|\\?|\\"|\\=|\\/|\\:|\\\\|\\ |\\@]',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text(AppLocalizations.of(context).cancel),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            if (Platform.isAndroid)
                              TextButton.icon(
                                icon: Icon(
                                  Icons.save,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                label: Text(AppLocalizations.of(context).save),
                                onPressed: () async {
                                  if (!await _getStoragePermission()) {
                                    return;
                                  }
                                  try {
                                    String value = await DatabaseHelper.instance
                                        .generateBackup();
                                    downloadPath =
                                        '/storage/emulated/0/Download';
                                    File backupFile = File(
                                      '$downloadPath/${fileNameController.text}.txt',
                                    );
                                    await backupFile.writeAsString(value);
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop('save');
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).backupError,
                                          ),
                                        ),
                                      );
                                  }
                                },
                              ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pop(fileNameController.text);
                              },
                              icon: Platform.isAndroid
                                  ? Icon(
                                      Icons.share,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  : Container(),
                              label: Text(
                                Platform.isAndroid
                                    ? AppLocalizations.of(context).share
                                    : AppLocalizations.of(context).continue_,
                              ),
                            ),
                          ],
                        );
                      },
                    ).then((String? backupName) async {
                      if (backupName != null) {
                        if (backupName == 'save') {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).savedTo(downloadPath),
                                ),
                              ),
                            );
                        } else {
                          try {
                            Directory directory = await getTemporaryDirectory();
                            downloadPath = directory.path;
                            String backupValue = await DatabaseHelper.instance
                                .generateBackup();
                            File backupFile = File(
                              '$downloadPath/$backupName.txt',
                            );
                            await backupFile.writeAsString(backupValue);
                            if (!context.mounted) return;
                            await SharePlus.instance.share(
                              ShareParams(
                                files: [XFile('$downloadPath/$backupName.txt')],
                                sharePositionOrigin:
                                    Offset(
                                      MediaQuery.of(context).size.height / 2,
                                      MediaQuery.of(context).size.width / 2,
                                    ) &
                                    const Size(3.0, 4.0),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context).backupError,
                                  ),
                                ),
                              );
                          }
                        }
                      }
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: Text(AppLocalizations.of(context).restore),
                  subtitle: Text(
                    AppLocalizations.of(context).restoreDescription,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  onTap: () async {
                    final bool? choice = await showDialog<bool?>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Container(
                            constraints: const BoxConstraints(
                              maxWidth: maxDialogWidth,
                            ),
                            child: Text(
                              AppLocalizations.of(context).restoreWarning,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text(AppLocalizations.of(context).cancel),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: Text(
                                AppLocalizations.of(context).continue_,
                              ),
                              onPressed: () async {
                                if (!await _getStoragePermission()) {
                                  return;
                                }
                                if (!context.mounted) return;
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (choice == null || !choice) {
                      return;
                    }
                    await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowMultiple: false,
                          allowedExtensions: ['txt'],
                        )
                        .then((FilePickerResult? result) async {
                          if (result != null) {
                            String contents;
                            String? path = result.files.single.path;
                            if (path == null) {
                              return;
                            }
                            File file = File(path);
                            contents = file.readAsStringSync();

                            if (!context.mounted) return;
                            _showLoaderDialog(context);
                            try {
                              await DatabaseHelper.instance.restoreBackup(
                                contents,
                              );
                              SharedPrefs().initialPage = 0;
                              if (!context.mounted) return;
                              await context
                                  .read<CharactersModel>()
                                  .loadCharacters();
                              if (!context.mounted) return;
                              context.read<CharactersModel>().jumpToPage(0);
                            } catch (e) {
                              if (!context.mounted) return;
                              await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).errorDuringRestore,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineLarge,
                                    ),
                                    actions: [
                                      TextButton.icon(
                                        onPressed: () => Clipboard.setData(
                                          ClipboardData(text: e.toString()),
                                        ),
                                        icon: const Icon(Icons.copy),
                                        label: Text(
                                          AppLocalizations.of(context).copy,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(
                                          AppLocalizations.of(context).close,
                                        ),
                                      ),
                                    ],
                                    content: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: maxDialogWidth,
                                      ),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).restoreErrorMessage(e.toString()),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          }
                        });
                  },
                ),
                if (kDebugMode) ...[
                  SettingsSection(title: AppLocalizations.of(context).testing),
                  ListTile(
                    title: Text(AppLocalizations.of(context).createAll),
                    onTap: () => context
                        .read<CharactersModel>()
                        .createCharactersTest(includeAllVariants: true),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context).gloomhaven),
                    onTap: () =>
                        context.read<CharactersModel>().createCharactersTest(
                          classCategory: ClassCategory.gloomhaven,
                        ),
                  ),
                  ListTile(
                    title: Text(
                      '${AppLocalizations.of(context).gloomhaven} ${AppLocalizations.of(context).andVariants}',
                    ),
                    onTap: () =>
                        context.read<CharactersModel>().createCharactersTest(
                          classCategory: ClassCategory.gloomhaven,
                          includeAllVariants: true,
                        ),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context).frosthaven),
                    onTap: () =>
                        context.read<CharactersModel>().createCharactersTest(
                          classCategory: ClassCategory.frosthaven,
                        ),
                  ),
                  ListTile(
                    title: Text(
                      '${AppLocalizations.of(context).frosthaven} ${AppLocalizations.of(context).andVariants}',
                    ),
                    onTap: () =>
                        context.read<CharactersModel>().createCharactersTest(
                          classCategory: ClassCategory.frosthaven,
                          includeAllVariants: true,
                        ),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context).crimsonScales),
                    onTap: () =>
                        context.read<CharactersModel>().createCharactersTest(
                          classCategory: ClassCategory.crimsonScales,
                        ),
                  ),
                  ListTile(
                    title: Text(
                      '${AppLocalizations.of(context).crimsonScales} ${AppLocalizations.of(context).andVariants}',
                    ),
                    onTap: () =>
                        context.read<CharactersModel>().createCharactersTest(
                          classCategory: ClassCategory.crimsonScales,
                          includeAllVariants: true,
                        ),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context).custom),
                    onTap: () =>
                        context.read<CharactersModel>().createCharactersTest(
                          classCategory: ClassCategory.custom,
                        ),
                  ),
                  ListTile(
                    title: Text(
                      '${AppLocalizations.of(context).custom} ${AppLocalizations.of(context).andVariants}',
                    ),
                    onTap: () =>
                        context.read<CharactersModel>().createCharactersTest(
                          classCategory: ClassCategory.custom,
                          includeAllVariants: true,
                        ),
                  ),
                ],
                // Extra padding to scroll content above bottom sheet
                const SizedBox(height: 160),
              ],
            ),
          ),
        ),
        bottomSheet: FutureBuilder(
          future: _packageInfoFuture,
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final theme = Theme.of(context);
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      theme.bottomNavigationBarTheme.backgroundColor ??
                      theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).supportAndFeedback,
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.discord),
                          onPressed: () {
                            _launchURL(
                              Uri(
                                scheme: 'https',
                                host: 'discord.gg',
                                path: 'UwuGf4hdnA',
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.instagram),
                          onPressed: () async {
                            await _launchURL(
                              Uri(
                                scheme: 'https',
                                host: 'instagram.com',
                                path: 'tomkatcreative',
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.email),
                          onPressed: () async {
                            final deviceInfo = await _getDeviceInfo();
                            final appVersion = snapshot.data != null
                                ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                                : 'Unknown';

                            final emailBody =
                                '''
    App Version: $appVersion
    Platform: ${Platform.isIOS ? 'iOS' : 'Android'}
      $deviceInfo
    
    --- Please describe your issue or provide your feedback below ---
    
    ''';

                            await _launchURL(
                              Uri.parse(
                                'mailto:tomkatcreative@gmail.com'
                                '?subject=${Uri.encodeComponent('GHC Support & Feedback')}'
                                '&body=${Uri.encodeComponent(emailBody)}',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (kDebugMode ||
                        (Platform.isAndroid && SharedPrefs().isUSRegion))
                      IconButton(
                        icon: SvgPicture.asset(
                          'images/branding/bmc-button.svg',
                          height: 32,
                        ),
                        tooltip: 'Buy Me a Coffee',
                        onPressed: () {
                          _launchURL(
                            Uri(
                              scheme: 'https',
                              host: 'buymeacoffee.com',
                              path: '/tomkatcreative',
                            ),
                          );
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: mediumPadding,
                        right: mediumPadding,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'v${snapshot.data!.version} ',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChangelogScreen(),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context).changelog,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          GestureDetector(
                            onTap: () {
                              _launchURL(
                                Uri.parse(
                                  'https://creativecommons.org/licenses/by-nc-sa/4.0/',
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context).license,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}

Future<bool> _getStoragePermission() async {
  if (Platform.isAndroid) {
    return true;
  }
  PermissionStatus permissionStatus = await Permission.storage.request();
  if (permissionStatus.isGranted) {
    return true;
  } else if (permissionStatus.isPermanentlyDenied) {
    await openAppSettings();
  } else if (permissionStatus.isDenied) {
    return false;
  }
  return false;
}

void _showLoaderDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            Container(
              constraints: const BoxConstraints(maxWidth: maxDialogWidth),
              margin: const EdgeInsets.only(left: 7),
              child: Text(AppLocalizations.of(context).restoring),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _launchURL(Uri uri) async => await canLaunchUrl(uri)
    ? await launchUrl(uri, mode: LaunchMode.externalApplication)
    : await launchUrl(uri);

Future<String> _getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return 'Device: ${iosInfo.utsname.machine}\n'
        'OS Version: iOS ${iosInfo.systemVersion}';
  } else if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return 'Device: ${androidInfo.manufacturer} ${androidInfo.model}\n'
        'OS Version: Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
  }

  return 'Device: Unknown';
}

class SettingsSection extends StatelessWidget {
  final String title;
  const SettingsSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
