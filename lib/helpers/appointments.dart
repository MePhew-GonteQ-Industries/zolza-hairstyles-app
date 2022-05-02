import 'dart:ffi';

class Appointment {
  final String id;
  final bool occupied;
  final bool reserved;
  final dynamic reservedReason;
  final bool holiday;
  final bool sunday;
  final bool breakTime;
  final dynamic startTime;
  final dynamic endTime;
  final dynamic holidayName;

  const Appointment({
    required this.id,
    required this.occupied,
    required this.reserved,
    required this.reservedReason,
    required this.holiday,
    required this.sunday,
    required this.breakTime,
    required this.startTime,
    required this.endTime,
    required this.holidayName,
  });

  static Appointment fromJson(json) => Appointment(
        id: json['id'],
        occupied: json['occupied'],
        reserved: json['reserved'],
        reservedReason: json['reserved_reason'],
        holiday: json['holiday'],
        sunday: json['sunday'],
        breakTime: json['break_time'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        holidayName: json['holiday_name'],
      );
}
