import 'dart:convert';

class User {
  String? name;
  String? desc;
  String? date;
  String? status;
  bool? alarm;
  User({this.name, this.desc, this.date, this.status, this.alarm});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      desc: json['desc'],
      date: json['date'],
      status: json['status'],
      alarm: json['alarm'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': desc,
      'date': date,
      'status': status,
      'alarm': alarm
    };
  }
}
