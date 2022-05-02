import 'package:flutter/material.dart';
import 'package:hairdressing_salon_app/screens/checkforloggeduser.dart';
import 'package:hairdressing_salon_app/screens/confirmappointment.dart';
import 'package:hairdressing_salon_app/screens/selecthourscreen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'colors.dart';
import 'screens/appointmentsscreen.dart';
import 'screens/contactscreen.dart';
import 'screens/forgotpasswordscreen.dart';
import 'screens/loginscreen.dart';
import 'screens/profilescreen.dart';
import 'screens/servicesscreen.dart';
import 'screens/homescreen.dart';
import 'screens/registrationscreen.dart';
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
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
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
        textTheme: ThemeData.light().textTheme,
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
        textTheme: ThemeData.dark().textTheme,
        cardColor: lightComplementaryColor,
        canvasColor: lightBackgroundColor,
      ).copyWith(
        scaffoldBackgroundColor: darkBackgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/checkForLoggedIn',
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
