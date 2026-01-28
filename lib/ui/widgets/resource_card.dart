import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';

import 'package:gloomhaven_enhancement_calc/models/resource.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final Color color;
  final int count;
  final Function() onIncrease;
  final Function() onDecrease;
  final bool canEdit;
  const ResourceCard({
    super.key,
    required this.resource,
    required this.color,
    required this.count,
    required this.onIncrease,
    required this.onDecrease,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: canEdit ? 100 : 75,
      width: 100,
      child: Card(
        child: ResourceDetails(
          resource: resource,
          color: color,
          count: count,
          decreaseCount: onDecrease,
          increaseCount: onIncrease,
          canEdit: canEdit,
        ),
      ),
    );
  }
}

class ResourceDetails extends StatelessWidget {
  final Resource resource;
  final Color color;
  final int count;
  final Function() decreaseCount;
  final Function() increaseCount;
  final bool canEdit;
  const ResourceDetails({
    super.key,
    required this.resource,
    required this.color,
    required this.count,
    required this.decreaseCount,
    required this.increaseCount,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: AutoSizeText(resource.name, maxLines: 1, maxFontSize: 18),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Center(
            child: SvgPicture.asset(
              resource.icon,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        ),
        Positioned(
          bottom: canEdit ? null : 8,
          child: Center(child: Text('$count')),
        ),
        if (canEdit) ...[
          Positioned(
            bottom: -mediumPadding,
            left: -2,
            child: IconButton(
              onPressed: () => decreaseCount(),
              icon: const Icon(Icons.remove_circle),
            ),
          ),
          Positioned(
            bottom: -mediumPadding,
            right: -2,
            child: IconButton(
              onPressed: () => increaseCount(),
              icon: const Icon(Icons.add_circle),
            ),
          ),
        ],
      ],
    );
  }
}
