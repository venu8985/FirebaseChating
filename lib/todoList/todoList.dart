import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/controllers/notificationService.dart';
import 'package:test_project/controllers/todoController.dart';
import 'package:test_project/models/todoListModel.dart';
import 'package:test_project/todoList/addTask.dart';
import 'package:test_project/todoList/alarm.dart';
import 'package:test_project/todoList/showTask.dart';

class TodoListMain extends StatefulWidget {
  const TodoListMain({super.key});

  @override
  State<TodoListMain> createState() => _TodoListMainState();
}

class _TodoListMainState extends State<TodoListMain> {
  var controller = Get.put(TodoController());
  @override
  void initState() {
    // TODO: implement initState
    controller.getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        automaticallyImplyLeading: false,
        actions: [Icon(Icons.search)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(AddTask());
        },
      ),
      body: Center(
        child: Obx(() {
          return ListView.builder(
            itemCount: controller.allData.length,
            itemBuilder: (context, index) {
              DateTime key = controller.allData.keys.elementAt(index);
              List<User> userList = controller.allData[key] ??
                  []; // Get the user list for the current key
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text("Date: ${key.toString()}"), // Display the date
                  Column(
                    children: userList.map((user) {
                      DateTime date = DateTime.parse(user.date!);
                      String formattedDate =
                          DateFormat('dd MMM yyyy').format(date);
                      return Card(
                        child: ListTile(
                          trailing: Text(user.status ?? ''),

                          onTap: () async {
                            controller.titleController.value.text =
                                user.name.toString();
                            controller.subtitle.value.text =
                                user.desc.toString();
                            controller.status.value = user.status.toString();
                            // Get.to(AddTask());
                            // Get.to(AlarmPage());
                            // await NotificationService()
                            //     .showNotification(1, 'venu', 'yes');
                            Get.to(ShowTask(
                              user: user,
                            ));
                          },

                          title: Text(
                            user.name ?? '',
                          ), // Display user information
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.desc ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(formattedDate)
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
