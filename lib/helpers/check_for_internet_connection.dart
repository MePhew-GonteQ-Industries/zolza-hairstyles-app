import 'package:connectivity_plus/connectivity_plus.dart';

class Connection {
  late List<ConnectivityResult> result;

  Connection({
    required this.result,
  });
  void checkForInternetConnection() async {
    result = await Connectivity().checkConnectivity();
  }
}
