class AccidentReport {
  final String id;
  final String location;
  final DateTime time;
  final String photoPath; // video URL / media
  final String status;
  final double latitude;
  final double longitude;
  final String cameraId;
   //final String ;
  final String? ambulanceId; // nullable: assigned ambulance

  AccidentReport({
    required this.id,
    required this.location,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.photoPath,
    required this.cameraId,
    this.ambulanceId,
    this.status = "Pending",
  });

  factory AccidentReport.fromJson(Map<String, dynamic> json) {
    return AccidentReport(
      id: json['id'].toString(),
      location: json['location'] ?? '',
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      time: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      photoPath: json['video_url'] ?? '',
      cameraId: json['camera_id'].toString(),
      ambulanceId: json['ambu_id']?.toString(),
      status: json['status'] ?? "Pending",
    );
  }
}