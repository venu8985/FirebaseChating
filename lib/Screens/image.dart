import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:vicky_gpt/loader_helper.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({Key? key}) : super(key: key);

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  GenerateContentResponse? response;
  final ImagePicker _picker = ImagePicker();
  List<String> base64Images = [];

  Future<void> getData(String myRequest) async {
    try {
      LoaderHelper.showLoader(context);
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: "AIzaSyDoQLuQFYnrbyTy3Ru5KNIvkhTCl20_aw8",
      );

      // Combine text and image data into a single string or JSON
      final imageData =
          base64Images.map((base64) => '"image":"$base64"').join(',');
      final combinedRequest = '{"text":"$myRequest",$imageData}';

      // Prepare content as a single text input containing the combined request
      final content = [Content.text(combinedRequest)];

      // Token count
      final tokenCount = await model.countTokens(content);
      print('Token count: ${tokenCount.totalTokens}');

      // Check token count
      if (tokenCount.totalTokens > 18000) {
        // Adjust limit based on API documentation
        throw Exception("image size exceded. Please reduce image size.");
      }

      response = await model.generateContent(content);
      print(response?.text);

      LoaderHelper.hideLoader(context);
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
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressedFile = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        minWidth: 800,
        minHeight: 800,
        quality: 15, // Reduce quality for smaller size
      );
      if (compressedFile != null) {
        final base64String = base64Encode(compressedFile);
        setState(() {
          base64Images.add(base64String);
        });
      }
    }
  }

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 119, 49, 72),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select your image',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () async {
                    await pickImage();
                  },
                  icon: Icon(Icons.image),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter your Query...',
                suffixIcon: GestureDetector(
                  onTap: () {
                    controller.clear();
                  },
                  child: Icon(Icons.close),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // UI to select images
            Wrap(
              spacing: 8.0,
              children: base64Images.asMap().entries.map((entry) {
                final int index = entry.key;
                final String base64 = entry.value;

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Implement logic to remove image from selection if needed
                        setState(() {
                          base64Images.removeAt(index);
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: MemoryImage(base64Decode(base64)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            base64Images.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: size.width / 1.2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 119, 49, 72),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      getData(controller.text);
                    },
                    child: Text('Get Result'),
                  ),
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
            SizedBox(height: 20),
            response?.text != null
                ? SelectableText(response!.text!)
                : Container(
                    height: 200,
                    width: double.infinity,
                    child: Icon(
                      Icons.image,
                      size: 300,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
