import 'package:flutter/material.dart';

class TrackingProvider with ChangeNotifier {
  String _location = "Unknown";

  String get location => _location;

  void updateLocation(String newLocation) {
    _location = newLocation;
    notifyListeners();
  }
}
