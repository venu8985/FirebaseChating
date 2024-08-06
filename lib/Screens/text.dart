import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vicky_gpt/Screens/image.dart';
import 'package:vicky_gpt/loader_helper.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  GenerateContentResponse? response;
  Future<void> getData(String myRequest) async {
    try {
      LoaderHelper.showLoader(context);
      final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: "AIzaSyDoQLuQFYnrbyTy3Ru5KNIvkhTCl20_aw8");
      final content = [Content.text(myRequest)];
      response = await model.generateContent(content);
      print(response?.text);
      LoaderHelper.hideLoader(context);
      FocusScope.of(context).unfocus();
      setState(() {});
    } catch (e) {
      LoaderHelper.hideLoader(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.only(bottom: 10, right: 20, left: 20),
      ));
      print(e);
    } finally {
      FocusScope.of(context).unfocus();
    }
  }

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Vicky GPT'),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/logo.png'),
            ),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 119, 49, 72),
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Text Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: controller,
                // onChanged: (value) {
                //   controller.text = value;
                // },
                decoration: InputDecoration(
                    hintText: 'Enter your Query...',
                    suffixIcon: GestureDetector(
                        onTap: () {
                          controller.clear();
                        },
                        child: Icon(Icons.close)),
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: size.width / 1.2,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 119, 49, 72),
                            foregroundColor: Colors.white),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          getData(controller.text);
                        },
                        child: Text('Get Result')),
                  ),
                  InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(
                            text: response?.text.toString() ?? "Copy Again"));

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Copied'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                          showCloseIcon: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          margin:
                              EdgeInsets.only(bottom: 10, right: 20, left: 20),
                        ));
                      },
                      child: Icon(Icons.copy))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              response?.text.toString() != null
                  ? SelectableText(response?.text.toString() ?? "")
                  : Container(
                      height: 200,
                      width: double.infinity,
                      child: Icon(
                        Icons.chat,
                        size: 300,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    )
            ],
          ),
        ));
  }
}
