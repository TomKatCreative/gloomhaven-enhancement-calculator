import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

class Mastery {
  late String id;
  late String classCode;
  late String masteryDetails;
  Variant variant = Variant.base;

  /// Stable identity number for this mastery within its class+variant group.
  ///
  /// Used to generate mastery IDs that are independent of list position.
  /// Must be unique within each (classCode, variant) pair.
  final int number;

  Mastery(this.number, {required this.masteryDetails});
}

class Masteries {
  Masteries(this.masteries, {this.variant = Variant.base});

  List<Mastery> masteries;
  Variant variant;
}
