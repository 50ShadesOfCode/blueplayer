import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class UploadFile extends StatefulWidget {
  @override
  _UploadFileState createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  Future<String> uploadAudio(filename, url) async {
    var req = http.MultipartRequest('POST', Uri.parse(url));
    req.files.add(await http.MultipartFile.fromPath('audio', filename));
    print(req.url);
    var res = await req.send();
    return res.reasonPhrase;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload song on server"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                FilePickerResult res =
                    await FilePicker.platform.pickFiles(type: FileType.audio);
                if (res != null) {
                  var resp = uploadAudio(
                      res.files.first.path, "http://192.168.42.41:8080/upload");
                  print(resp);
                }
              },
              child: Text("Upload song"),
            ),
          ],
        ),
      ),
    );
  }
}
