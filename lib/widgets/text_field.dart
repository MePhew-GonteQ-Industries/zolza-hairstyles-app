import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFieldWidget {
  Widget textField(BuildContext context, TextEditingController controller,
      String hint, IconData icon, bool isObscure, TextInputType type) {
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
            style: GoogleFonts.poppins(
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
              hintStyle: GoogleFonts.poppins(
                color: Theme.of(context).hintColor,
              ),
            ),
            obscureText: isObscure,
            keyboardType: type,
          ),
        ),
      ],
    );
  }
}
