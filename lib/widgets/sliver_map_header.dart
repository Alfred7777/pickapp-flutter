import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/eventRepository.dart';

class SliverMapHeader implements SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final LatLng markerPos;

  SliverMapHeader({
    @required this.minExtent,
    @required this.maxExtent,
    @required this.markerPos,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(getStaticEventLocationMapString(markerPos, 16)),
          fit: BoxFit.cover,
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300],
            width: 0.6,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  TickerProvider get vsync => null;
}
