import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hairdressing_salon_app/fcm/send_fcm_token.dart';
import 'package:http/http.dart';
import '../helpers/user_secure_storage.dart';

class GetFcmToken {
  Future<void> setUpToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    // await sendFCMToken(token!);
    Response fcmtoken = await sendFCMToken(token!);
    await UserSecureStorage.setFCMToken(token);
    print(token);
    print(fcmtoken.statusCode);
    print(fcmtoken.body);
    // FirebaseMessaging.instance.onTokenRefresh.listen(sendFCMToken(token!));
  }
}
