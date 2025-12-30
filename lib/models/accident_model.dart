class AccidentReport {
  final String id;
  final String location;
  final String time;
  final String photoPath; // server image path
  final String status;

  AccidentReport({
    required this.id,
    required this.location,
    required this.time,
    required this.photoPath,
    required this.status,
  });

  factory AccidentReport.fromJson(Map<String, dynamic> json) {
    return AccidentReport(
      id: json['id'].toString(),                // 🔥 int → String
      location: json['location'] ?? '',
      time: json['timestamp'].toString(),       // 🔥 backend uses timestamp
      photoPath: json['image'] ?? '',           // 🔥 backend uses image
      status: json['status'] ?? 'Pending',
    );
  }
}
