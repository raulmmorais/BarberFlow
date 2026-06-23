import 'package:barberflow/app.dart';
import 'package:barberflow/core/services/firebase_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const BarberFlowApp());
}
