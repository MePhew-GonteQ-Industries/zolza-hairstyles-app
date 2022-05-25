import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
import 'package:http/http.dart' as http;

Future<http.Response> sendFCMToken(String token) {
  return http.post(Uri.parse(TemporaryStorage.apiUrl));
}
