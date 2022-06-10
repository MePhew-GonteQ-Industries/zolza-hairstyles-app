import 'dart:convert';
import 'package:hairdressing_salon_app/helpers/temporary_storage.dart';
import 'package:http/http.dart' as http;

Map<String, String> headers = {
  'Authorization': 'Bearer ${TemporaryStorage.accessToken}',
  'Content-Type': 'application/json',
};

Future<http.Response> createAppointment() {
  return http.post(
    Uri.parse(TemporaryStorage.apiUrl + '/appointments'),
    headers: headers,
    body: jsonEncode(<String, String>{
      'service_id': TemporaryStorage.serviceID,
      'first_slot_id': TemporaryStorage.appointmentID,
    }),
  );
}
