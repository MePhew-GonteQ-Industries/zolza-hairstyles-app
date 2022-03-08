import 'package:hairdressing_salon_app/helpers/services.dart';
import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class ServicesApi {
  static Future<List<Service>> getServices(BuildContext context) async {
    final response = await http.get(
        Uri.parse(
          'https://mephew.ddns.net/api/services',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $TemporaryStorage.accessToken',
        }).timeout(
      const Duration(seconds: 4),
      onTimeout: () => http.Response('Error', 408),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    return body.map<Service>(Service.fromJson).toList();
  }
}
