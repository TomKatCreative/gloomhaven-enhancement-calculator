import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

class Perk {
  late String perkId;
  late String classCode;
  late int quantity;
  late String perkDetails;
  bool grouped = false;
  Variant variant = Variant.base;

  /// Stable identity number for this perk within its class+variant group.
  ///
  /// Used to generate perk IDs that are independent of list position.
  /// Must be unique within each (classCode, variant) pair.
  final int number;

  Perk(
    this.number,
    this.perkDetails, {
    this.quantity = 1,
    this.grouped = false,
  });
}

class Perks {
  Perks(this.perks, {required this.variant});

  List<Perk> perks;
  Variant variant;
}
