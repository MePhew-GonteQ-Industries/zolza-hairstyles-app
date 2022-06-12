import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';

import './appointments.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

Map<String, String> headers = {
  'Authorization': 'Bearer ${UserData.accessToken}',
  'Content-Type': 'application/json',
};

class AppointmentsApi {
  static Future<List<Appointment>> getAppointments(
      BuildContext context, String date) async {
    final response = await http.get(
      Uri.parse('$apiUrl/appointments/slots?date=$date'),
      headers: headers,
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    return body.map<Appointment>(Appointment.fromJson).toList();
  }
}
