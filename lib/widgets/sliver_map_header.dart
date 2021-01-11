import 'package:PickApp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/utils/static_google_map.dart';

class SliverMapHeader implements SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final LatLng markerPos;
  final Widget privacyBadge;

  SliverMapHeader({
    @required this.minExtent,
    @required this.maxExtent,
    @required this.markerPos,
    @required this.privacyBadge,
  });

  void _redirectToNavigation() async {
    var url;
    if (Theme.of(navigatorKey.currentContext).platform == TargetPlatform.iOS) {
      url =
          'https://maps.apple.com/?q=${markerPos.latitude},${markerPos.longitude}';
    } else {
      url =
          'https://www.google.com/maps/search/?api=1&query=${markerPos.latitude},${markerPos.longitude}';
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      await showDialog(
        context: navigatorKey.currentContext,
        builder: (BuildContext context) {
          return ErrorDialog(
            redirectToNavigation: _redirectToNavigation,
          );
        },
      );
    }
  }

  void _showRedirectDialog() {
    showDialog(
      context: navigatorKey.currentContext,
      builder: (BuildContext context) {
        return RedirectDialog(
          redirectToNavigation: _redirectToNavigation,
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(
      children: [
        InkWell(
          onTap: _showRedirectDialog,
          child: Padding(
            padding: EdgeInsets.only(bottom: 18),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    StaticGoogleMap.getStaticMarkerMapString(markerPos, 16),
                  ),
                  fit: BoxFit.cover,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300],
                    width: 0.6,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 24,
          bottom: 0,
          child: privacyBadge ?? Container(),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration {
    return null;
  }

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  TickerProvider get vsync => null;
}

class RedirectDialog extends StatelessWidget {
  final Function redirectToNavigation;

  const RedirectDialog({
    @required this.redirectToNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm navigation'),
      content: Text('Do you want to be navigated to this location?'),
      actions: [
        FlatButton(
          child: Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop();
            redirectToNavigation();
          },
        ),
        FlatButton(
          child: Text('Go Back'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final Function redirectToNavigation;

  const ErrorDialog({
    @required this.redirectToNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('An Error Occured!'),
      content: Text('Could not launch map!'),
      actions: [
        FlatButton(
          child: Text('Try Again'),
          onPressed: () {
            Navigator.of(context).pop();
            redirectToNavigation();
          },
        ),
        FlatButton(
          child: Text('Go Back'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
