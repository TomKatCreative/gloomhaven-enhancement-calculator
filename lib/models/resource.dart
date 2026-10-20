import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';

/// The nine Frosthaven crafting resources a character can hold.
///
/// Declared in the Characters table's column order, because the create-table
/// SQL is generated from [Resource.values] and the migration tests compare it
/// byte for byte. The sheet shows them in [displayOrder] instead.
enum Resource {
  hide(columnResourceHide, 'HIDE'),
  metal(columnResourceMetal, 'METAL'),
  lumber(columnResourceLumber, 'LUMBER'),
  arrowvine(columnResourceArrowvine, 'ARROWVINE'),
  axenut(columnResourceAxenut, 'AXENUT'),
  rockroot(columnResourceRockroot, 'ROCKROOT'),
  flamefruit(columnResourceFlamefruit, 'FLAMEFRUIT'),
  corpsecap(columnResourceCorpsecap, 'CORPSECAP'),
  snowthistle(columnResourceSnowthistle, 'SNOWTHISTLE');

  const Resource(this.column, this.assetKey);

  /// The Characters table column holding this resource's count.
  final String column;

  /// The `asset_config.dart` key for this resource's icon.
  final String assetKey;

  /// The order the Resources section shows them in: materials, then herbs
  /// alphabetically.
  static const displayOrder = [
    lumber,
    metal,
    hide,
    arrowvine,
    axenut,
    corpsecap,
    flamefruit,
    rockroot,
    snowthistle,
  ];

  String label(AppLocalizations l10n) => switch (this) {
    hide => l10n.resourceHide,
    metal => l10n.resourceMetal,
    lumber => l10n.resourceLumber,
    arrowvine => l10n.resourceArrowvine,
    axenut => l10n.resourceAxenut,
    rockroot => l10n.resourceRockroot,
    flamefruit => l10n.resourceFlamefruit,
    corpsecap => l10n.resourceCorpsecap,
    snowthistle => l10n.resourceSnowthistle,
  };
}
