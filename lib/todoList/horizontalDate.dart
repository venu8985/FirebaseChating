// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Person {
//   final String name;
//   final String description;
//   final String time;

//   Person({
//     required this.name,
//     required this.description,
//     required this.time,
//   });
// }

// class HorizontalDateList extends StatefulWidget {
//   @override
//   State<HorizontalDateList> createState() => _HorizontalDateListState();
// }

// class _HorizontalDateListState extends State<HorizontalDateList> {
//   final List<Person> personList = [];
//   final nameController = TextEditingController();
//   final descriptionController = TextEditingController();

//   final Map<DateTime, List<Person>> _dateWiseData = {};
//   DateTime? selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     DateTime currentDate = DateTime.now();
//     DateTime date =
//         DateTime(currentDate.year, currentDate.month, currentDate.day);
//     selectedDate = date;
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _dateWiseData.clear();
//     for (String key in prefs.getKeys()) {
//       DateTime date = DateTime.parse(key);

//       List<String>? personData = prefs.getStringList(key);
//       if (personData != null) {
//         _dateWiseData[date] = personData.map((data) {
//           List<String> parts = data.split('|');
//           return Person(name: parts[0], description: parts[1], time: parts[2]);
//         }).toList();
//       }
//     }
//   }

//   Future<void> _saveData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     for (DateTime date in _dateWiseData.keys) {
//       List<String> personData = _dateWiseData[date]!
//           .map(
//               (person) => '${person.name}|${person.description}|${person.time}')
//           .toList();
//       prefs.setStringList(date.toString(), personData);
//     }
//   }

//   Future<void> _removeTask(DateTime date, Person person) async {
//     List<Person>? tasks = _dateWiseData[date];
//     if (tasks != null) {
//       tasks.remove(person);
//       await _saveData();
//       setState(() {
//         personList.remove(person);
//       });

//       if (_dateWiseData.containsKey(date)) {
//         personList.addAll(_dateWiseData[date]!);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     DateTime currentDate = DateTime.now();
//     int daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${selectedDate?.toString().split(' ')[0] ?? ""}'),
//         centerTitle: true,
//         elevation: 10,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           SizedBox(height: 30),
//           Flexible(
//             child: Container(
//               height: 90,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: daysInMonth,
//                 itemBuilder: (context, index) {
//                   DateTime date =
//                       DateTime(currentDate.year, currentDate.month, index + 1);
//                   return GestureDetector(
//                     onTap: () async {
//                       setState(() {
//                         selectedDate = date;
//                       });
//                       await _loadDataForSelectedDate(date);
//                     },
//                     child: Container(
//                       height: 30,
//                       margin: EdgeInsets.all(5.0),
//                       padding: EdgeInsets.all(10.0),
//                       decoration: BoxDecoration(
//                         border: Border.all(),
//                         borderRadius: BorderRadius.circular(10.0),
//                         color: selectedDate == date
//                             ? Colors.red.withOpacity(0.7)
//                             : null,
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           Text(
//                             '${date.day}',
//                             style: TextStyle(
//                                 color: selectedDate == date
//                                     ? Colors.white
//                                     : Colors.black,
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '${_getWeekdayName(date.weekday)}',
//                             style: TextStyle(
//                               fontSize: 16.0,
//                               color: selectedDate == date
//                                   ? Colors.white
//                                   : Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Staff',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 20),
//           personList.length == 0
//               ? Center(
//                   child: Padding(
//                   padding: const EdgeInsets.only(top: 150),
//                   child: Text('No Data'),
//                 ))
//               : Expanded(
//                   child: ListView.builder(
//                     itemCount: personList.length,
//                     itemBuilder: (context, index) {
//                       return Card(
//                         child: ListTile(
//                           title: Text(personList[index].name),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                   'Description: ${personList[index].description}'),
//                               Text('Time: ${personList[index].time}'),
//                             ],
//                           ),
//                           trailing: IconButton(
//                             icon: Icon(Icons.delete),
//                             onPressed: () async {
//                               await _removeTask(
//                                   selectedDate!, personList[index]);
//                               setState(() {});
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           //  Get.to(page)
//           // showDialog(
//           //     context: context,
//           //     builder: (context) {
//           //       return AlertDialog(
//           //         title: Center(child: Text('SVAM')),
//           //         content: Column(
//           //           mainAxisSize: MainAxisSize.min,
//           //           children: [
//           //             TextFormField(
//           //               minLines: 1,
//           //               maxLines: 4,
//           //               controller: nameController,
//           //               decoration: InputDecoration(
//           //                 hintText: 'Enter your task',
//           //                 border: OutlineInputBorder(
//           //                   borderRadius: BorderRadius.circular(15),
//           //                 ),
//           //               ),
//           //             ),
//           //             SizedBox(height: 10),
//           //             TextFormField(
//           //               minLines: 1,
//           //               maxLines: 4,
//           //               controller: descriptionController,
//           //               decoration: InputDecoration(
//           //                 hintText: 'Enter task description',
//           //                 border: OutlineInputBorder(
//           //                   borderRadius: BorderRadius.circular(15),
//           //                 ),
//           //               ),
//           //             ),
//           //           ],
//           //         ),
//           //         actions: [
//           //           GestureDetector(
//           //             onTap: () async {
//           //               String name = nameController.text;
//           //               String description = descriptionController.text;
//           //               String time = DateTime.now().toString();
//           //               // Get current time
//           //               setState(() {
//           //                 if (name.isNotEmpty) {
//           //                   personList.add(Person(
//           //                     name: name,
//           //                     description: description,
//           //                     time: time,
//           //                   ));
//           //                   if (selectedDate != null) {
//           //                     if (!_dateWiseData.containsKey(selectedDate)) {
//           //                       _dateWiseData[selectedDate!] = [];
//           //                     }
//           //                     _dateWiseData[selectedDate!]!.add(Person(
//           //                       name: name,
//           //                       description: description,
//           //                       time: time,
//           //                     ));
//           //                   }

//           //                   nameController.clear();
//           //                   descriptionController.clear();
//           //                 }
//           //               });
//           //               await _saveData();
//           //               Navigator.of(context).pop();
//           //             },
//           //             child: Text('Add'),
//           //           ),
//           //         ],
//           //       );
//           //     });
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   String _getWeekdayName(int weekday) {
//     switch (weekday) {
//       case 1:
//         return 'Mon';
//       case 2:
//         return 'Tue';
//       case 3:
//         return 'Wed';
//       case 4:
//         return 'Thu';
//       case 5:
//         return 'Fri';
//       case 6:
//         return 'Sat';
//       case 7:
//         return 'Sun';
//       default:
//         return '';
//     }
//   }

//   Future<void> _loadDataForSelectedDate(DateTime date) async {
//     setState(() {
//       personList.clear();
//       if (_dateWiseData.containsKey(date)) {
//         personList.addAll(_dateWiseData[date]!);
//       }
//     });
//   }
// }
