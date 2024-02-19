import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  late File _image;
  late Map<String, dynamic>? _output;
  final imagepicker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future pickimageCamera() async {
    final pickedFile = await imagepicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        loading = true;
      });

      // Create a multipart request
      var url = Uri.parse('https://api-predict-cn4xadzzta-et.a.run.app/predict');
      var request = http.MultipartRequest('POST', url);

      // Attach the image file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Send the request to the API
      var response = await request.send();

      // Parse the response from the API
      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) {
          setState(() {
            _output = jsonDecode(value);
            loading = false;
          });
        });
      } else {
        print('Failed to upload image: ${response.statusCode}');
      }
    }
  }

  pickimageGallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
      setState(() {
        loading = true;
      });

      // Create a multipart request
      var url = Uri.parse('https://api-predict-cn4xadzzta-et.a.run.app/predict');
      var request = http.MultipartRequest('POST', url);

      // Attach the image file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Send the request to the API
      var response = await request.send();

      // Parse the response from the API
      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) {
          setState(() {
            _output = jsonDecode(value);
            loading = false;
          });
        });
      } else {
        print('Failed to upload image: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Project Dhila',
          style: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
      body: SizedBox(
        height: h,
        width: w,
        child: Column(
          children: [
            Container(
              height: 150,
              width: 150,
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/autismlogo.png'),
            ),
            Container(
                child: const Text('Autism Detection',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ))),
            const SizedBox(height: 50),
            Container(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 197, 38, 245),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Capture',
                            style:
                                TextStyle(fontFamily: 'Roboto', fontSize: 18)),
                        onPressed: () {
                          pickimageCamera();
                        }),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 63, 57, 65),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Gallery',
                            style:
                                TextStyle(fontFamily: 'Roboto', fontSize: 18)),
                        onPressed: () {
                          pickimageGallery();
                        }),
                  ),
                ],
              ),
            ),
            loading != true
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          height: 220,
                          // width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          child: Image.file(_image),
                        ),
                        _output != null
                            ? Text((_output?['predicted_label']).toString(),
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ))
                            : const Text(''),
                        _output != null
                            ? Text(
                                'Confidence: ' +
                                    (_output?['confidence_score']).toString(),
                                style: const TextStyle(
                                    fontFamily: 'Roboto', fontSize: 18))
                            : const Text(''),
                        _output != null
                            ? Text(
                                'Time: ' +
                                    (_output?['elapsed_time']).toString(),
                                style: const TextStyle(
                                    fontFamily: 'Roboto', fontSize: 18))
                            : const Text('')
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
