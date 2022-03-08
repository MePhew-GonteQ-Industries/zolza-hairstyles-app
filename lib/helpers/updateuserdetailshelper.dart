import 'dart:convert';
import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
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
        Uri.parse('https://mephew.ddns.net/api/users/me/update-details'),
        headers: {
          'Authorization': 'Bearer ${TemporaryStorage.accessToken}',
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
        const Duration(seconds: 4),
        onTimeout: () => http.Response('Error', 408),
      );
}

Future<http.Response> enterSudoMode(String password) {
  return http.post(
    Uri.parse('https://mephew.ddns.net/api/auth/enter-sudo-mode'),
    headers: {
      'Authorization': 'Bearer ${TemporaryStorage.accessToken}',
    },
    body: {
      'password': password,
    },
  ).timeout(
    const Duration(seconds: 4),
    onTimeout: () => http.Response('Error', 408),
  );
}

Future<http.Response> changeUserPassword(
    String oldPassword, String newPassword) {
  return http
      .post(
        Uri.parse('https://mephew.ddns.net/api/auth/change-password'),
        headers: {
          'Authorization': 'Bearer ${TemporaryStorage.accessToken}',
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
        const Duration(seconds: 4),
        onTimeout: () => http.Response('Error', 408),
      );
}
