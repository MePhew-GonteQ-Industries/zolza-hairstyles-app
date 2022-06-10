import 'package:hairdressing_salon_app/helpers/temporary_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

Map<String, String> headers = {
  'Authorization': 'Bearer ${TemporaryStorage.accessToken}'
};

Future<http.Response> logOutUser() async {
  return http
      .post(
        Uri.parse('${TemporaryStorage.apiUrl}/auth/logout'),
        headers: headers,
      )
      .timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('Error', 408),
      );
}
