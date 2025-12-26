class AccidentReport {
  final String id;
  final String location;
  final String time;
  final String photoPath;
  final String status;

  AccidentReport({
    required this.id,
    required this.location,
    required this.time,
    required this.photoPath,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'time': time,
      'photoPath': photoPath,
      'status': status,
    };
  }

  factory AccidentReport.fromJson(Map<String, dynamic> json) {
    return AccidentReport(
      id: json['id'],
      location: json['location'],
      time: json['time'],
      photoPath: json['photoPath'],
      status: json['status'],
    );
  }
}