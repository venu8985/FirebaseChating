import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/controllers/todoController.dart';
import 'package:test_project/models/todoListModel.dart';
import 'package:test_project/todoList/todoList.dart';

class ShowTask extends StatefulWidget {
  final User? user;
  const ShowTask({super.key, this.user});

  @override
  State<ShowTask> createState() => _ShowTaskState();
}

class _ShowTaskState extends State<ShowTask> {
  var controller = Get.put(TodoController());
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  List<User> personList = [];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('---');
            String name = controller.titleController.value.text;
            String description = controller.subtitle.value.text;
            String time = widget.user!.date!;
            String status = controller.status.value.toString();
            bool alarm = false;
            // Get current time
            personList.clear();
            setState(() {
              personList.add(User(
                  name: name,
                  desc: description,
                  status: status,
                  alarm: alarm,
                  date: time));
            });
            saveData();
            // saveData();
          },
          child: Icon(Icons.my_library_books_rounded),
        ),
        appBar: AppBar(
          title: Text(controller.status.value.toString()),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                controller.status.value = value;
                print(value); // Print the selected value
              },
              itemBuilder: (context) => [
                PopupMenuItem(child: Text('Pending'), value: 'Pending'),
                PopupMenuItem(child: Text('Complete'), value: 'Complete'),
                PopupMenuItem(child: Text('Delete'), value: 'Delete'),
              ],
            ),
          ],
        ),
        body: Obx(() {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  minLines: 1,
                  maxLines: 2,
                  controller: controller.titleController.value,
                  style: TextStyle(fontSize: 22.0, color: Colors.green),
                  decoration: InputDecoration(
                      hintText: 'Enter title', border: InputBorder.none),
                ),
                SizedBox(height: 10),
                Text(DateFormat('dd MMM yyyy /')
                    .add_jms()
                    .format(DateTime.parse(widget.user!.date.toString()))
                    .toString()),
                TextFormField(
                  minLines: 1,
                  maxLines: 500,
                  controller: controller.subtitle.value,
                  decoration: InputDecoration(
                      hintText: 'Enter task description',
                      border: InputBorder.none),
                ),
              ],
            ),
          );
        }),
      );
    });
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> serializedList =
        personList.map((user) => jsonEncode(user.toJson())).toList();

    DateTime userDate = DateTime.parse(widget.user!.date!.split('.')[0]);
    String dateString = userDate.toString();
    DateTime dateTime = DateTime.parse(dateString);

    String formattedDateTime = dateTime.toString().split('.')[0];
    print(formattedDateTime);
    print(dateString);

    await prefs.setStringList("${dateString}", serializedList);

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
