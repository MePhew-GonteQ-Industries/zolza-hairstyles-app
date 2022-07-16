import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hairdressing_salon_app/fcm/send_fcm_token.dart';
import '../helpers/user_secure_storage.dart';

class GetFcmToken {
  Future<void> setUpToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    sendFCMToken(token!);
    await UserSecureStorage.setFCMToken(token);
    print(token);
  }
}
