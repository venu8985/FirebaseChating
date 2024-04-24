import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('VPN Check Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
     checkVPN();
              // Call the checkVPN function when the button is clicked
              // bool isVpnConnected = await checkVPN();
              // if (isVpnConnected) {
              //   // Alert user about potential VPN connection
              //   print('Potential VPN connection detected');
              //   // You can add UI elements or show a dialog to inform the user
              // } else {
              //   // No VPN detected
              //   print('No VPN detected');
              //   // You can add UI elements or show a dialog to inform the user
              // }
            },
            child: Text('Check VPN'),
          ),
        ),
      ),
    );
  }
}

Future<void> checkVPN() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.vpn) {
        print(connectivityResult.toString());
        // VPN is connected
        print('VPN is connected');
        // You can add UI elements or show a dialog to inform the user
      } else {
          print(connectivityResult.toString());
        // No VPN detected
        print('No VPN detected');
        // You can add UI elements or show a dialog to inform the user
      }
    } catch (e) {
      // Handle exceptions
      print('Error checking VPN: $e');
    }
  }

Future<String> getDeviceIpAddress() async {
  try {
    HttpClientRequest request = await HttpClient().getUrl(Uri.parse('https://api64.ipify.org?format=json'));
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();

    Map<String, dynamic> ipInfo = json.decode(responseBody);

    return ipInfo['ip'];
  } catch (e) {
    print('Error getting device IP address: $e');
    throw e; // Re-throw the error to propagate it to the caller
  }
}
class VPNCheck {
  static const MethodChannel _channel = MethodChannel('vpn_check');

  static Future isVpnConnected() async {
    
}
  }
