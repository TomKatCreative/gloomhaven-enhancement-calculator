import 'package:gloomhaven_enhancement_calc/models/character.dart';

class ResourceFieldData {
  final String name;
  final int Function(Character) getter;
  final void Function(Character, int) setter;

  /// Asset key is derived from [name] by uppercasing.
  String get assetKey => name.toUpperCase();

  ResourceFieldData({
    required this.name,
    required this.getter,
    required this.setter,
  });
}

final List<ResourceFieldData> resourceFields = [
  ResourceFieldData(
    name: 'Lumber',
    getter: (character) => character.resourceLumber,
    setter: (character, value) => character.resourceLumber = value,
  ),
  ResourceFieldData(
    name: 'Metal',
    getter: (character) => character.resourceMetal,
    setter: (character, value) => character.resourceMetal = value,
  ),
  ResourceFieldData(
    name: 'Hide',
    getter: (character) => character.resourceHide,
    setter: (character, value) => character.resourceHide = value,
  ),
  ResourceFieldData(
    name: 'Arrowvine',
    getter: (character) => character.resourceArrowvine,
    setter: (character, value) => character.resourceArrowvine = value,
  ),
  ResourceFieldData(
    name: 'Axenut',
    getter: (character) => character.resourceAxenut,
    setter: (character, value) => character.resourceAxenut = value,
  ),
  ResourceFieldData(
    name: 'Corpsecap',
    getter: (character) => character.resourceCorpsecap,
    setter: (character, value) => character.resourceCorpsecap = value,
  ),
  ResourceFieldData(
    name: 'Flamefruit',
    getter: (character) => character.resourceFlamefruit,
    setter: (character, value) => character.resourceFlamefruit = value,
  ),
  ResourceFieldData(
    name: 'Rockroot',
    getter: (character) => character.resourceRockroot,
    setter: (character, value) => character.resourceRockroot = value,
  ),
  ResourceFieldData(
    name: 'Snowthistle',
    getter: (character) => character.resourceSnowthistle,
    setter: (character, value) => character.resourceSnowthistle = value,
  ),
];
