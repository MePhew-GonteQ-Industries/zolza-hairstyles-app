import 'package:flutter/material.dart';

class SelectHourScreen extends StatefulWidget {
  const SelectHourScreen({Key? key}) : super(key: key);

  @override
  _SelectHourState createState() => _SelectHourState();
}

class _SelectHourState extends State<SelectHourScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        title: Text(
          'Wybierz godzinę',
          style: TextStyle(
            color: Theme.of(context).backgroundColor,
          ),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }
}
