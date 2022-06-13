import 'dart:convert';
import 'package:hairdressing_salon_app/helpers/login.dart';
import 'package:hairdressing_salon_app/helpers/user_secure_storage.dart';
import 'package:http/http.dart' as http;

// regainAccessToken() async {
//   final refreshToken = UserSecureStorage.getRefreshToken();
//   http.Response regainAccessTokenResponse =
//       await sendRefreshToken(refreshToken);
//   final parsedJson = jsonDecode(regainAccessTokenResponse.body);
//   return <String, dynamic>{
//     'statusCode': regainAccessTokenResponse.statusCode,
//     'data': parsedJson,
//   };
// }

// Future<http.Response> regainAccessToken() async {
//   final refreshToken = UserSecureStorage.getRefreshToken();
  
// }
