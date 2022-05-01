import 'package:flutter/material.dart';

class NoAppointment {
  Widget center(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Wygląda na to\nże nie masz umówionej wizyty,\nkliknij przycisk aby to zrobić',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5,
              padding: const EdgeInsets.all(13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              primary: Theme.of(context).primaryColorDark,
              shadowColor: const Color(0xCC007AF3),
            ),
            child: const Text('Umów wizytę',
                style: TextStyle(
                  color: Colors.white,
                )),
            onPressed: () {
              Navigator.pushNamed(context, '/services');
            },
          ),
        ],
      ),
    );
  }
}
