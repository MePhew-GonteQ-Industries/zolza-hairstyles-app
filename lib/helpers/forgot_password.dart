import 'dart:async';
import 'dart:convert';
import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:http/http.dart' as http;

Future<http.Response> forgotPassword(String email) async {
  return http
      .post(
        Uri.parse('$apiUrl/auth/request-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      )
      .timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('Error', 408),
      );
}
