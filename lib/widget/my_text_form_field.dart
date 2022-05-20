import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final String labeltext;
  Function(String? value) onSaved;
  Function(String? value) validator;
  final bool isPassword;
  final bool isEmail;
  bool showEyeIcon;
  bool showDropDownIcon;
  int maximumLine;
  bool isEditAble;
  IconData iconData;
  TextInputType typeText;
  Function(String? value) callBackPasswordView;
  Function(String? value)? callOnChangedValue;
  TextEditingController? controller;

  MyTextFormField({
    Key? key,
    required this.hintText,
    required this.onSaved,
    required this.validator,
    this.controller,
    this.iconData = Icons.keyboard_arrow_down_sharp,
    this.isPassword = false,
    this.isEditAble = true,
    this.isEmail = false,
    this.showDropDownIcon = false,
    required this.callBackPasswordView,
    this.callOnChangedValue,
    this.showEyeIcon = false,
    this.typeText = TextInputType.text,
    this.maximumLine = 1,
    this.labeltext = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: isEditAble,
      onChanged: (value)=>callOnChangedValue!(value),
      maxLines: 1,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        // floatingLabelBehavior: FloatingLabelBehavior.never,
        //hide the

        //textError styling
        errorStyle: TextStyle(color: Colors.pink),
        hintStyle: TextStyle(color: Colors.grey),
        labelStyle: TextStyle(color: Colors.grey),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: controller!.text.isEmpty ? Colors.grey : Colors.grey[200]!,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.green,
            width: 1.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: controller!.text.isEmpty?Colors.grey:Colors.green,
            width: 1.0,
          ),
        ),
        labelText: labeltext ,
        suffixIcon: showEyeIcon
            ? IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              !isPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[200],
            ),
            onPressed: () => callBackPasswordView("test"))
            : showDropDownIcon
            ? IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            iconData,
            color: Colors.green,
            size: 27,
          ),
          onPressed: () {},
        )
            : const SizedBox(),
        hintText: hintText,
        contentPadding: const EdgeInsets.only(left: 15.0),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
      ),
      obscureText: isPassword ? true : false,
      validator: (value) => validator(value),
      onSaved: (value) => onSaved(value),
      keyboardType: isEmail ? TextInputType.emailAddress : typeText,
    );
  }
}
