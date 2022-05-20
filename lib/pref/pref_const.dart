import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class Pref {
  static String? getValue(String keyWord) {
    return GetStorage().read(keyWord);
  }

  static Future<dynamic> setValue(String keyWord, String value) {
    return GetStorage().write(keyWord, value);
  }

  static Future<dynamic> setObject(String keyWord, dynamic object) {
    return GetStorage().write(keyWord, json.encode(object));
  }
  static dynamic getObject(String keyWord) {
    return  json.decode(GetStorage().read(keyWord));
  }

  static Future<dynamic> removeValue(String keyWord) {
    return GetStorage().remove(keyWord);
  }
  static Future<dynamic> removeAllValue() {
    return GetStorage().erase();
  }
}
