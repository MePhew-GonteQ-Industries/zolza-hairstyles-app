import 'package:intl/intl.dart';

class TemporaryStorage {
  static String accessToken = 'AccessToken';
  static String name = 'Imię';
  static String surName = 'Nazwisko';
  static String email = 'email@email.email';
  static String gender = 'Płeć';
  static String service = 'Usługa';
  static String apiUrl = 'https://zolza-hairstyles.pl/api';
  static String serviceID = 'serviceID';
  static int serviceAverageDuration = 30;
  static String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
  static String appointmentID = 'appointmentID';
  static String startHour = 'hour';
  static int requiredSlots = 0;
}
