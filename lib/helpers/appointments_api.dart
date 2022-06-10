import './appointments.dart';
import './temporary_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

Map<String, String> headers = {
  'Authorization': 'Bearer ${TemporaryStorage.accessToken}',
  'Content-Type': 'application/json',
};

class AppointmentsApi {
  static Future<List<Appointment>> getAppointments(
      BuildContext context, String date) async {
    final response = await http.get(
      Uri.parse('${TemporaryStorage.apiUrl}/appointments/slots?date=${TemporaryStorage.date}'),
      headers: headers,
    );
    // print(response.body);
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    // print(body);
    return body.map<Appointment>(Appointment.fromJson).toList();
  }
}
