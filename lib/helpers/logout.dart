import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

Map<String, String> headers = {
  'Authorization': 'Bearer ${UserData.accessToken}'
};

Future<http.Response> logOutUser() async {
  return http
      .post(
        Uri.parse('$apiUrl/auth/logout'),
        headers: headers,
      )
      .timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('Error', 408),
      );
}
