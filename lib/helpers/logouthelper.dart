import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

Map<String, String> headers = {
  'Authorization': 'Bearer ${TemporaryStorage.accessToken}'
};

Future<http.Response> logOutUser() async {
  return http
      .post(
        Uri.parse('https://mephew.ddns.net/api/auth/logout'),
        headers: headers,
      )
      .timeout(
        const Duration(seconds: 4),
        onTimeout: () => http.Response('Error', 408),
      );
}
