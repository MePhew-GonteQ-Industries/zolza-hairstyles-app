import 'package:flutter/material.dart';

class TextFieldWidget {
  Widget textField(BuildContext context, TextEditingController controller,
      String hint, IconData icon, bool isObscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          height: 50,
          child: TextField(
            controller: controller,
            cursorColor: Theme.of(context).backgroundColor,
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 12),
              prefixIcon: Icon(
                icon,
                color: Theme.of(context).backgroundColor,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(context).hintColor,
              ),
            ),
            obscureText: isObscure,
          ),
        ),
      ],
    );
  }
}
