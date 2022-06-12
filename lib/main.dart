import 'package:flutter/material.dart';
import 'package:hairdressing_salon_app/screens/check_for_logged_in_user.dart';
import 'package:hairdressing_salon_app/screens/confirm_appointment.dart';
import 'package:hairdressing_salon_app/screens/select_hours.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'colors.dart';
import 'screens/appointments.dart';
import 'screens/contact.dart';
import 'screens/forgot_password.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/services.dart';
import 'screens/home.dart';
import 'screens/registration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_core/firebase_core.dart';

// FirebaseMessaging messaging = FirebaseMessaging.instance;

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State {
  // @override
  // void initState() {
  //   super.initState();
  //   FirebaseMessaging.instance.getInitialMessage();
  //   FirebaseMessaging.onMessage.listen((message) {
  //     if (message.notification != null) {
  //       print(message.notification!.title);
  //       print(message.notification!.body);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zołza Hairstyles',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primaryColor: lightPrimaryColor,
        shadowColor: lightPrimaryColorShadow,
        backgroundColor: lightBackgroundColor,
        hintColor: lightBackgroundColorShadow,
        primaryColorDark: lightComplementaryColor,
        scaffoldBackgroundColor: lightBackgroundColor,
        bottomAppBarColor: Colors.black,
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyText2: const TextStyle(
                color: lightAccentColor,
              ),
            ),
        cardColor: lightPrimaryColor,
        canvasColor: lightBackgroundColor,
      ),
      darkTheme: ThemeData(
        primaryColor: darkPrimaryColor,
        shadowColor: darkPrimaryColorShadow,
        backgroundColor: darkBackgroundColor,
        hintColor: darkBackgroundColorShadow,
        primaryColorDark: lightComplementaryColor,
        scaffoldBackgroundColor: darkBackgroundColor,
        bottomAppBarColor: lightBackgroundColor,
        textTheme: ThemeData.dark().textTheme.copyWith(
              bodyText2: const TextStyle(
                color: darkAccentColor,
              ),
            ),
        cardColor: lightComplementaryColor,
        canvasColor: lightBackgroundColor,
      ).copyWith(
        scaffoldBackgroundColor: darkBackgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/checkForLoggedIn',
      // initialRoute: '/login',
      // initialRoute: '/home',
      // initialRoute: '/appointments',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/services': (context) => const ServicesScreen(),
        '/contact': (context) => const ContactScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/checkForLoggedIn': (context) => const CheckForLoggedUserScreen(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/selectHour': (context) => const SelectHourScreen(),
        '/confirmAppointment': (context) => const ConfirmAppointment(),
      },
    );
  }
}
