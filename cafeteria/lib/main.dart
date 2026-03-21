import 'package:flutter/material.dart';
import 'features/auth/di/injaction.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}



