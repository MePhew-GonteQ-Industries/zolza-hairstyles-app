import 'dart:convert';

import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
import 'package:http/http.dart' as http;

Future<http.Response> verifyUser() async {
  return http
      .post(
    Uri.parse(TemporaryStorage.apiUrl + '/users/request-email-verification'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(
      <String, String>{
        'email': TemporaryStorage.email,
      },
    ),
  )
      .timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      return http.Response('Error', 408);
    },
  );
}
