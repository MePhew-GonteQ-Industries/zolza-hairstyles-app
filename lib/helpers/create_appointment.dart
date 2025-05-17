import 'dart:convert';
import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:hairdressing_salon_app/helpers/appointment_data.dart';
import 'package:hairdressing_salon_app/helpers/service_data.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:http/http.dart' as http;

Map<String, String> headers = {
  'Authorization': 'Bearer ${UserData.accessToken}',
  'Content-Type': 'application/json',
};

Future<http.Response> createAppointment() {
  return http.post(
    Uri.parse('$apiUrl/appointments'),
    headers: headers,
    body: jsonEncode(<String, String>{
      'service_id': ServiceData.id,
      'first_slot_id': AppointmentData.id,
    }),
  );
}
