import 'dart:convert';

import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:http/http.dart' as http;

Future<http.Response> verifyUser() async {
  return http
      .post(
    Uri.parse('$apiUrl/users/request-email-verification'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(
      <String, String>{
        'email': UserData.email,
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
