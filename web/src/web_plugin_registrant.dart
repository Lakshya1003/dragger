// This file is auto-generated. Do not edit or all your changes will be lost.
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:sign_in_with_apple_web/sign_in_with_apple_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:firebase_storage_web/firebase_storage_web.dart';
import 'package:firebase_database_web/firebase_database_web.dart';

void registerPlugins([final Registrar? registrar]) {
  SharedPreferencesPlugin.registerWith(registrar ?? webPluginRegistrar);
  SignInWithApplePlugin.registerWith(registrar ?? webPluginRegistrar);
  FirebaseCoreWeb.registerWith(registrar ?? webPluginRegistrar);
  FirebaseAuthWeb.registerWith(registrar ?? webPluginRegistrar);
  FirebaseFirestoreWeb.registerWith(registrar ?? webPluginRegistrar);
  FirebaseStorageWeb.registerWith(registrar ?? webPluginRegistrar);
  FirebaseDatabaseWeb.registerWith(registrar ?? webPluginRegistrar);
}
