import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

class FirebaseNotification {
  static Future<int> sendNotification(String token, String message) async {
    // Generate a random 4-digit number

    try {
      final body = {
        "to": token,
        //this will vary
        "notification": {
          "title": "Dental PNU",
          "body": message,
          "android_channel_id": ""
        },
        "data": {
          "some_data": "User ID: ${FirebaseAuth.instance.currentUser!.uid}",
        },
      };
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: "application/json",
                HttpHeaders.authorizationHeader:
                    "key = AAAA8BBLy4Q:APA91bFprTT9pdMXAAZVzFKzdKDYlM1LvqvznqmrvwiZJ4ll4Ecu79cZvC6ZPqMZ_aAiPd4PagQQ0OqDblWGhDsHTU9JoZJsrgx5rL8mwibdk9qbd4zOKOB9u9KZztUsNmWIGlDHIMod"
              },
              body: jsonEncode(body));
      //Utilities().showMessage('Confirming Your Order. Please Wait!!');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      final dateTime = DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      print("Error $e");
    }
    return 0;
  }
}
