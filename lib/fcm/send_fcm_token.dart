import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:http/http.dart' as http;

Future<http.Response> sendFCMToken(String token) {
  return http.post(
    Uri.parse(apiUrl),
    // Uri.parse($apiUrl/notifications/add_token),
    // headers: {
    //   'Content-Type': 'application/json',
    //   'Authorization': 'Bearer ${UserData.accessToken}',
    // },
    // body: {
    //   'fcm_token': token,
    // },
  );
}
