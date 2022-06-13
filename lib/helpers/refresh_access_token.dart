// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hairdressing_salon_app/helpers/login.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:hairdressing_salon_app/helpers/user_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../widgets/alerts.dart';

void refreshAccessToken(BuildContext context) async {
  String refreshToken = UserSecureStorage.getRefreshToken();
  http.Response response = await sendRefreshToken(refreshToken);
  if (response.statusCode == 200) {
    final parsedJson = jsonDecode(response.body);
    await UserSecureStorage.setRefreshToken(parsedJson['refresh_token']);
    UserData.accessToken = parsedJson['access_token'];
  } else if (response.statusCode == 401) {
    Alerts().alertSessionExpired(context);
  }
}
