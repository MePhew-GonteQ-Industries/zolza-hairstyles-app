import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:hairdressing_salon_app/helpers/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class ServicesApi {
  static Future<List<Service>> getServices(BuildContext context) async {
    final response = await http.get(
      Uri.parse(
        '$apiUrl/services',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => http.Response('Error', 408),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    return body.map<Service>(Service.fromJson).toList();
  }
}
