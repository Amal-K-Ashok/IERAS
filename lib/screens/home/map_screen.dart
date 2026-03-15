import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/screens/tracking/tracking_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final String accidentId;

  const MapScreen({super.key, required this.accidentId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  GoogleMapController? mapController;
  RealtimeChannel? channel;

  LatLng _initialPosition = const LatLng(10.8505, 76.2711);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  LatLng? userLatLng;
  LatLng? ambulanceLatLng;

  double? distanceInKm;
  String? estimatedTime;
  String? ambulanceId;
  bool isLoading = true;

  final Color primaryColor = const Color.fromARGB(255, 25, 50, 92);

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    if (channel != null) {
      supabase.removeChannel(channel!);
    }
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    await _getUserLocation();
    await _getAmbulanceId();
    setState(() => isLoading = false);
  }

  // ---------------- USER LOCATION ----------------
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    userLatLng = LatLng(position.latitude, position.longitude);

    _markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: userLatLng!,
        infoWindow: const InfoWindow(title: "You are here"),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue),
      ),
    );

    _initialPosition = userLatLng!;
  }

  // ---------------- GET AMBULANCE ----------------
  Future<void> _getAmbulanceId() async {
    try {
      final response = await supabase
          .from('accidents')
          .select('ambu_id')
          .eq('id', widget.accidentId)
          .single();

      if (response['ambu_id'] == null) return;

      ambulanceId = response['ambu_id'].toString();

      await _getLatestAmbulanceLocation();
      _listenToAmbulance();
    } catch (e) {
      debugPrint("Error fetching ambulance: $e");
    }
  }

  Future<void> _getLatestAmbulanceLocation() async {
    if (ambulanceId == null) return;

    final response = await supabase
        .from('ambulance_tracking')
        .select('latitude, longitude')
        .eq('tracking_id', ambulanceId!)
        .order('updated_at', ascending: false)
        .limit(1)
        .single();

    double lat = double.parse(response['latitude'].toString());
    double lng = double.parse(response['longitude'].toString());

    _updateAmbulanceMarker(LatLng(lat, lng));
  }

  // ---------------- REALTIME ----------------
  void _listenToAmbulance() {
    if (ambulanceId == null) return;

    channel = supabase.channel('ambulance_tracking_channel')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'ambulance_tracking',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'tracking_id',
          value: ambulanceId!,
        ),
        callback: (payload) {
          double? lat = double.tryParse(
              payload.newRecord['latitude'].toString());
          double? lng = double.tryParse(
              payload.newRecord['longitude'].toString());

          if (lat != null && lng != null) {
            _updateAmbulanceMarker(LatLng(lat, lng));
          }
        },
      )
      ..subscribe();
  }

  // ---------------- UPDATE MARKER ----------------
  void _updateAmbulanceMarker(LatLng position) {
    ambulanceLatLng = position;

    _markers.removeWhere(
        (m) => m.markerId.value == 'ambulance');

    _markers.add(
      Marker(
        markerId: const MarkerId('ambulance'),
        position: position,
        infoWindow:
            const InfoWindow(title: "🚑 Ambulance"),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed),
      ),
    );

    _createRoutePolyline();

    mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15));

    setState(() {});
  }

  // ---------------- ROUTE + DISTANCE + ETA ----------------
  Future<void> _createRoutePolyline() async {
    if (userLatLng == null || ambulanceLatLng == null) return;

    final url =
        "https://router.project-osrm.org/route/v1/driving/"
        "${ambulanceLatLng!.longitude},${ambulanceLatLng!.latitude};"
        "${userLatLng!.longitude},${userLatLng!.latitude}"
        "?overview=full&geometries=geojson";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0];

      // ✅ REAL ROAD DISTANCE
      double distanceMeters = route['distance'];
      distanceInKm = distanceMeters / 1000;

      // ✅ REAL ROAD DURATION
      double durationSeconds = route['duration'];
      estimatedTime =
          "${(durationSeconds / 60).ceil()} min";

      List coordinates =
          route['geometry']['coordinates'];

      List<LatLng> routePoints = coordinates
          .map<LatLng>((coord) =>
              LatLng(coord[1], coord[0]))
          .toList();

      _polylines.clear();

      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: routePoints,
          width: 6,
          color: primaryColor,
        ),
      );

      setState(() {});
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambulance Tracking"),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(
                          target: _initialPosition,
                          zoom: 14),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                ),
               Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      if (ambulanceId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrackingScreen(
                                    accidentId:
                                        widget.accidentId),
                          ),
                        );
                      }
                    },
                    child: Card(
                      elevation: 8,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: ambulanceId == null
                            ? const Text(
                                "Waiting for ambulance assignment...")
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                      "🚑 Ambulance ID: $ambulanceId"),
                                  const SizedBox(
                                      height: 5),
                                  if (distanceInKm !=
                                      null)
                                    Text(
                                      "Distance: ${distanceInKm!.toStringAsFixed(2)} km",
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  if (estimatedTime !=
                                      null)
                                    Text(
                                      "Estimated Time: $estimatedTime",
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}