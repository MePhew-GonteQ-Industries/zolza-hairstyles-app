import 'package:hairdressing_salon_app/helpers/services.dart';
import 'package:hairdressing_salon_app/helpers/temporary_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class ServicesApi {
  static Future<List<Service>> getServices(BuildContext context) async {
    final response = await http.get(
        Uri.parse(
          '${TemporaryStorage.apiUrl}/services',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $TemporaryStorage.accessToken',
        }).timeout(
      const Duration(seconds: 10),
      onTimeout: () => http.Response('Error', 408),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    // print(body);
    return body.map<Service>(Service.fromJson).toList();
  }
}