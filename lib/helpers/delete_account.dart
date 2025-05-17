import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:http/http.dart' as http;

Future<http.Response> deleteUserAccount(
    String password, String accessToken) async {
  return http.put(
    Uri.parse('$apiUrl/users/me/delete'),
    headers: {
      // 'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: {
      'password': password.trim(),
    },
  ).timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      // Time has run out, do what you wanted to do.

      return http.Response('Error', 408);
    },
  );
}
