import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
import 'package:http/http.dart' as http;

Future<http.Response> sendFCMToken(String token) {
  return http.post(
    Uri.parse(TemporaryStorage.apiUrl + '/notifications/fcmtoken'),
    headers: {
      'Authorization': 'Bearer ${TemporaryStorage.accessToken}',
      'Content-Type': 'application/json',
    },
    body: {
      'fcmtoken': token,
    },
  );
}
