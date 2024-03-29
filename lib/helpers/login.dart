import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:http/http.dart' as http;

// Map<String, String> headers = {
//   'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
// };

Future<http.Response> loginUser(String email, String password) async {
  return http.post(
    Uri.parse('$apiUrl/auth/login'),
    body: {
      'grant_type': 'password',
      'username': email.trim(),
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

Future<http.Response> sendRefreshToken(String refreshToken) async {
  return http.post(
    Uri.parse('$apiUrl/auth/refresh-token'),
    body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    },
  ).timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      // Time has run out, do what you wanted to do.

      return http.Response('Error', 408);
    },
  );
}

Future<http.Response> getInfoRequest(String accessToken) async {
  return http.get(
    Uri.parse('$apiUrl/users/me'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  ).timeout(
    const Duration(seconds: 10),
    onTimeout: () => http.Response('Error', 408),
  );
}
