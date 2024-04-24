import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:test_project/controllers/notificationService.dart';
import 'package:test_project/paymentGateway/razorPay.dart';
import 'package:test_project/todoList/addTask.dart';
import 'package:test_project/todoList/horizontalDate.dart';
import 'package:test_project/todoList/todoList.dart';
import 'package:test_project/unNeccessary/vpn.dart';
import 'package:test_project/youtube/youtubeVedios.dart';
import 'package:uni_links/uni_links.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBcD0_Mlz73kSKMl1bCsTh7JRuuvJUFm4k",
      appId: "1:1031065553796:android:7232505c44262369d4ebd1",
      messagingSenderId: "1031065553796",
      projectId: "testproject-e520b",
    ),
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  String? token = await messaging.getToken();

  await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );
  await Alarm.init();
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

var a = 'n';

class _MyAppState extends State<MyApp> {
  Uri? _initialURI;
  Uri? _currentURI;
  Object? _err;
  bool? deeplink;
  StreamSubscription? _streamSubscription;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  // void _incomingLinkHandler() {
  //   if (!kIsWeb) {
  //     // It will handle app links while the app is already started - be it in
  //     // the foreground or in the background.
  //     _streamSubscription = uriLinkStream.listen((Uri? uri) {
  //       // if (!mounted) {
  //       //   return;
  //       // }
  //       a = uri!.path;
  //       if (uri!.path.contains("vouchers")) {
  //         Map<String, String> params =
  //             uri.queryParameters; // query parameters automatically populated
  //         int voucherId = int.parse(params['VoucherID'].toString());
  //         print(uri.path);
  //         print('++++++++++++++++++++');
  //         if (voucherId != 0) {
  //           Navigator.push(context,
  //               MaterialPageRoute(builder: (context) => YoutubeVideosScreen()));
  //         }
  //       } else {
  //         print('ok');
  //       }

  //       setState(() {
  //         _currentURI = uri;
  //         _err = null;
  //       });
  //     }, onError: (Object err) {
  //       if (!mounted) {
  //         return;
  //       }
  //       debugPrint('Error occurred: $err');

  //       setState(() {
  //         _currentURI = null;
  //         if (err is FormatException) {
  //           _err = err;
  //         } else {
  //           _err = null;
  //         }
  //       });
  //     });
  //   }
  // }

  bool _initialURILinkHandled = false;
  // Future<void> _initURIHandler() async {
  //   if (!_initialURILinkHandled) {
  //     _initialURILinkHandled = true;

  //     try {
  //       final initialURI = await getInitialUri();
  //       // Use the initialURI and warn the user if it is not correct,
  //       // but keep in mind it could be `null`.
  //       if (initialURI != null) {
  //         if (!mounted) {
  //           return;
  //         }
  //         setState(() {
  //           _initialURI = initialURI;
  //           print('&&&&&&&&&&&&& Link is ${initialURI} &&&&&&&&&&&&&');
  //           if (initialURI.path.contains("vouchers")) {
  //             Map<String, String> params = initialURI
  //                 .queryParameters; // query parameters automatically populated
  //             int voucherId = int.parse(params['VoucherID'].toString());
  //             if (voucherId != 0) {
  //               Navigator.push(context,
  //                   MaterialPageRoute(builder: (context) => YoutubeTest()));
  //             }
  //           }
  //         });
  //       } else {
  //         debugPrint("Null Initial URI received");
  //       }
  //     } catch (e) {
  //       print(e);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Razorpayment());
  }
}
