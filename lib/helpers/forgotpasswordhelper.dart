import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<http.Response> forgotPassword(String email) async {
  return http
      .post(
        Uri.parse('https://mephew.ddns.net/api/auth/request-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      )
      .timeout(
        const Duration(seconds: 4),
        onTimeout: () => http.Response('Error', 408),
      );
}
