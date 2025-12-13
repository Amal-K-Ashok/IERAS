import '../models/accident_model.dart';

class AccidentService {
  static final List<AccidentReport> _accidents = [];

  static void addAccident(AccidentReport report) {
    _accidents.add(report);
  }

  static List<AccidentReport> getAccidents() {
    return _accidents.reversed.toList(); // Latest first
  }
}
