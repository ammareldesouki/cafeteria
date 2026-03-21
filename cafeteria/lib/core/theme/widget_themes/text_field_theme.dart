import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    // constraints: const Boxconstraints.expand(heignt: 14. inputFietdHeight),
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: TColors.TextFormField,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: TColors.TextFormField,
    ),
    errorStyle: const TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      color: Colors.red,
    ),

    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(width: 2, color: TColors.TextFormField),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(width: 2, color: TColors.TextFormField),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(width: 2, color: TColors.TextFormField),
    ),

    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(width: 2, color: Colors.red),
    ),

    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(width: 2, color: Colors.orange),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    // constraints: const Boxconstraints.expand(heignt: 14. inputFietdHeight),
    labelStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.white),
    hintStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.white),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(
      color: Colors.black.withOpacity(0.8),
    ),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(width: 1, color: Colors.grey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(width: 1, color: Colors.grey),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(width: 1, color: Colors.grey),
    ),

    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(width: 1, color: Colors.red),
    ),

    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(width: 2, color: Colors.orange),
    ),
  );
}
