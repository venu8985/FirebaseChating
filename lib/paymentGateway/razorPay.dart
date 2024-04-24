import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Razorpayment extends StatefulWidget {
  const Razorpayment({
    super.key,
  });

  @override
  State<Razorpayment> createState() => _RazorpaymentState();
}

class _RazorpaymentState extends State<Razorpayment> {
  Razorpay? razorpay;
  @override
  void initState() {
    // TODO: implement initState
    razorpay = Razorpay();
    super.initState();
    razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
  }

  void makePayment() {
    var options = {
      //4O8Fa1baJtjPMyiglj9VV9Vu

      'key': 'rzp_test_d3nx3JAnC615DR',
      'amount': 100.00,
      'name': 'Svas',
      'description': 'Fine T-Shirt',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '7702645478', 'email': 'venuvvv111@gmail.com'},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      razorpay?.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Pay with Razorpay',
            ),
            ElevatedButton(
                onPressed: () {
                  makePayment();
                },
                child: const Text("Pay 200")),
          ],
        ),
      ),
    );
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    print('error');
    print(response);
    print(
        "Payment Failed Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    print(response.data?.entries);
    print('======');
    print(response.data);
    // showAlertDialog(
    //     context, "Payment Successful", "Payment ID: ${response.paymentId}");
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    print('++++');
    // showAlertDialog(
    //     context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
