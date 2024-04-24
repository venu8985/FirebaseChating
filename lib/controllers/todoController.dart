import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/models/todoListModel.dart';
import 'package:test_project/todoList/todoList.dart';

class TodoController extends GetxController {
  RxMap<DateTime, List<User>> allData = RxMap<DateTime, List<User>>();
  Rx<TextEditingController> titleController = TextEditingController().obs;
  Rx<TextEditingController> subtitle = TextEditingController().obs;
  Rx<String> status = ''.obs;

  var keydata = 0.obs;
  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    allData.clear();
    for (String key in prefs.getKeys()) {
      DateTime time = DateTime.parse(key);

      List<String>? userList = prefs.getStringList(key);
      if (userList != null) {
        List<User> users = userList
            .map((userString) => User.fromJson(jsonDecode(userString)))
            .toList();

        allData[DateTime.parse(time.toString().split('.')[0])] = users;
        keydata(allData.length);
        print(allData);
        update();
      }
    }
  }

  Future<void> removeTask(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime userDate = DateTime.parse(user.date!.split('.')[0]);
    String dateString = userDate.toString();
    DateTime dateTime = DateTime.parse(dateString);

    String formattedDateString = dateTime.toString().split('.')[0];
    print(formattedDateString);

    await prefs.remove(formattedDateString);
    print('+++${prefs.getKeys()}');

    allData.remove(userDate);

    update();
  }

  Future<void> updateTask(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime userDate = DateTime.parse(user.date!.split('.')[0]);
    String dateString = userDate.toString();
    DateTime dateTime = DateTime.parse(dateString);

    String formattedDateString = dateTime.toString().split('.')[0];
    print(formattedDateString);

    // await prefs.setStringList('', '');
    print('+++${prefs.getKeys()}');

    allData.remove(userDate);

    update();
  }
}
