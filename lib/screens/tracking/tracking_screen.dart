import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackingScreen extends StatefulWidget {
  final String accidentId;

  const TrackingScreen({super.key, required this.accidentId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<String> ambulanceIds = [];

  Map<String, String?> statusAmb = {};
  Map<String, String?> hospitals = {};
  Map<String, int> dynamicStatus = {};

  bool isLoading = true;
  String? selectedAmbulance;

  /// accident table value
  bool accidentCreated = false;

  final Color primaryColor = const Color.fromARGB(255, 25, 50, 92);

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    await _fetchAccidentData();

    for (var id in ambulanceIds) {
      await _fetchAmbulanceDetails(id);
      _updateDynamicStatus(id);
    }

    if (ambulanceIds.isNotEmpty) {
      selectedAmbulance = ambulanceIds.first;
    }

    setState(() {
      isLoading = false;
    });
  }

  /// FETCH accident table
  Future<void> _fetchAccidentData() async {
    final accidentResponse = await supabase
        .from('accidents')
        .select('id, ambu_id')
        .eq('id', widget.accidentId)
        .maybeSingle();

    if (accidentResponse != null) {
      if (accidentResponse['id'] != null) {
        accidentCreated = true;
      }

      if (accidentResponse['ambu_id'] != null &&
          accidentResponse['ambu_id'].toString().isNotEmpty) {
        ambulanceIds = accidentResponse['ambu_id']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
    }
  }

  /// FETCH ambulance_tracking table
  Future<void> _fetchAmbulanceDetails(String id) async {
    final response = await supabase
        .from('ambulance_tracking')
        .select('tracking_id, status_amb, Hos_name')
        .eq('tracking_id', id)
        .maybeSingle();

    if (response != null) {
      statusAmb[id] = response['status_amb']?.toString();
      hospitals[id] = response['Hos_name']?.toString();
    } else {
      statusAmb[id] = null;
      hospitals[id] = null;
    }
  }

  /// STATUS LOGIC
  void _updateDynamicStatus(String id) {
    int step = 0;

    /// Requested
    if (accidentCreated) {
      step = 0;
    }

    /// On the Way (tracking exists)
    if (statusAmb.containsKey(id) || hospitals.containsKey(id)) {
      step = 1;
    }

    /// Reached Location
    if (hospitals[id] != null && hospitals[id]!.isNotEmpty) {
      step = 2;
    }

    /// Completed
    if (statusAmb[id]?.toLowerCase() == "reached") {
      step = 3;
    }

    dynamicStatus[id] = step;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text(
          "Ambulance Tracking",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Column(
              children: [
                const SizedBox(height: 16),

                /// Ambulance selector
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ambulanceIds.length,
                    itemBuilder: (context, index) {
                      final ambId = ambulanceIds[index];
                      final isSelected = ambId == selectedAmbulance;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAmbulance = ambId;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 130,
                          margin: const EdgeInsets.only(right: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFC8E6C9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.grey.shade300,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_shipping,
                                size: 34,
                                color:
                                    isSelected ? primaryColor : Colors.green,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ambId,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                /// Tracking card
                if (selectedAmbulance != null)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListView(
                        children: [
                          Text(
                            "Tracking: $selectedAmbulance",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// Hospital message
                          if (dynamicStatus[selectedAmbulance!] == 3)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Text(
                                "Reached hospital: ${hospitals[selectedAmbulance!] ?? ''}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          _statusTile(
                              "Requested",
                              Icons.assignment_turned_in,
                              accidentCreated),

                          _statusTile(
                              "On the Way",
                              Icons.local_shipping,
                              (dynamicStatus[selectedAmbulance!] ?? 0) >= 1),

                          _statusTile(
                              "Reached Location",
                              Icons.location_on,
                              (dynamicStatus[selectedAmbulance!] ?? 0) >= 2),

                          _statusTile(
                              "Completed",
                              Icons.check_circle,
                              (dynamicStatus[selectedAmbulance!] ?? 0) >= 3),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _statusTile(String title, IconData icon, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: isActive ? Colors.green : Colors.grey),
          const SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
          const Spacer(),
          if (isActive)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}