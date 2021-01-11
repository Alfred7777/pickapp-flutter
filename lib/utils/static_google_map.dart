import 'package:google_maps_flutter/google_maps_flutter.dart';

class StaticGoogleMap {
  static String getStaticMarkerMapString(LatLng eventPos, int zoom) {
    var lat = eventPos.latitude;
    var lon = eventPos.longitude;
    var _apiUrl = 'https://maps.googleapis.com/maps/api/staticmap';
    var _apiKey = '&key=AIzaSyBQ6O79g3WKA7Xjf3-Z1DnB4SuRZXbNrug';
    var _imageSize = '?size=640x640';
    var _zoom = '&zoom=${zoom}';
    var _position = '&center=${lat},${lon}';
    var _marker = '&markers=color:red|${lat},${lon}';

    return _apiUrl + _imageSize + _zoom + _position + _marker + _apiKey;
  }
}
