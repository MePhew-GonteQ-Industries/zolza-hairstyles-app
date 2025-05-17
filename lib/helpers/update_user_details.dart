import 'dart:convert';
import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:http/http.dart' as http;

Future<http.Response> updateUserDetails(
  String name,
  String surName,
  String gender,
) {
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
      .put(
        Uri.parse('$apiUrl/users/me/update-details'),
        headers: {
          'Authorization': 'Bearer ${UserData.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'name': name,
            'surname': surName,
            'gender': gender,
          },
        ),
      )
      .timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('Error', 408),
      );
}

Future<http.Response> enterSudoMode(String password) {
  return http.post(
    Uri.parse('$apiUrl/auth/enter-sudo-mode'),
    headers: {
      'Authorization': 'Bearer ${UserData.accessToken}',
    },
    body: {
      'password': password,
    },
  ).timeout(
    const Duration(seconds: 10),
    onTimeout: () => http.Response('Error', 408),
  );
}

Future<http.Response> changeUserPassword(
    String oldPassword, String newPassword) {
  return http
      .post(
        Uri.parse('$apiUrl/auth/change-password'),
        headers: {
          'Authorization': 'Bearer ${UserData.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'old_password': oldPassword,
            'new_password': newPassword,
          },
        ),
      )
      .timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('Error', 408),
      );
}
