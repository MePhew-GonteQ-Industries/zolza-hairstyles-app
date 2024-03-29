import 'dart:async';
import 'dart:convert';
import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:http/http.dart' as http;

Future<http.Response> signUpUser(String name, String surname, String email,
    String password, String gender, String mode) async {
  switch (gender) {
    case 'Mężczyzna':
      gender = 'male';
      break;
    case 'Kobieta':
      gender = 'female';
      break;
    default:
      gender = 'other';
      break;
  }

  return http
      .post(
    Uri.parse('$apiUrl/users/register'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'content-language': 'pl',
      'preferred-theme': mode,
    },
    body: jsonEncode(
      <String, String>{
        'email': email.trim(),
        'name': name.trim(),
        'surname': surname.trim(),
        'gender': gender,
        'password': password.trim(),
      },
    ),
  )
      .timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      // Time has run out, do what you wanted to do.

      return http.Response('Error', 408);
    },
  );
}
