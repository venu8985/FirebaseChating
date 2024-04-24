import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/controllers/todoController.dart';
import 'package:test_project/models/todoListModel.dart';
import 'package:test_project/todoList/horizontalDate.dart';
import 'package:test_project/todoList/todoList.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  var controller = Get.put(TodoController());
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  List<User> personList = [];
  @override
  void initState() {
    // TODO: implement initState
    controller.titleController.value.clear();
    controller.subtitle.value.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('---');
          String name = controller.titleController.value.text;
          String description = controller.subtitle.value.text;
          String time = DateTime.now().toString();
          String status = 'pending';
          bool alarm = false;
          // Get current time
          personList.clear();

          personList.add(User(
              name: name,
              desc: description,
              date: time,
              status: status,
              alarm: alarm));

          saveData();
          // saveData();
        },
        child: Icon(Icons.my_library_books_rounded),
      ),
      appBar: AppBar(
        title: Text(''),
      ),
      body: Obx(() {
        return Column(
          children: [
            TextFormField(
              minLines: 1,
              maxLines: 2,
              controller: controller.titleController.value,
              decoration: InputDecoration(
                hintText: 'Enter title',
                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(15),
                // ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              minLines: 1,
              maxLines: 100,
              controller: controller.subtitle.value,
              decoration: InputDecoration(
                  hintText: 'Enter task description', border: InputBorder.none),
            ),
          ],
        );
      }),
    );
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> serializedList =
        personList.map((user) => jsonEncode(user.toJson())).toList();
    DateTime dateTime = DateTime.now();
    String formattedDateTime = dateTime.toString().split('.')[0];
    print(formattedDateTime);

    prefs.setStringList("${formattedDateTime}", serializedList);

    // print(serializedList);
    Get.to(TodoListMain());
  }

  // Future<void> updateData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   List<String> serializedList =
  //       personList.map((user) => jsonEncode(user.toJson())).toList();
  //   DateTime dateTime = serializedList.;
  //   String formattedDateTime = dateTime.toString().split('.')[0];
  //   print(formattedDateTime);

  //   prefs.setStringList("${}", serializedList);

  //   // print(serializedList);
  //   Get.to(TodoListMain());
  // }
}
