import 'dart:convert';
import 'dart:typed_data';

import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:d_input/d_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:d_info/d_info.dart';
import 'package:http/http.dart' as http;

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key, required this.cars});
  final Map cars;

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final descriptionController = TextEditingController();
  //XFile? xfile;
  String? newImageName;
  Uint8List? newImageByte;

  pickImage() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      newImageName = image.name;
      newImageByte = await image.readAsBytes();
      setState(() {});
    }
  }

  update() async {
    if (formKey.currentState!.validate()) {
      String url = 'http://192.168.1.27/task_crudmysql/car/update.php';
      var response = await http.post(Uri.parse(url), body: {
        'id': widget.cars['id'],
        'nama': namaController.text,
        'description': descriptionController.text,
        'old_image': widget.cars['image'],
        'new_image': newImageName ?? '',
        'new_base64code': base64Encode(List<int>.from(newImageByte ?? [])),
      });
      Map responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        DInfo.toastSuccess('Success Update');
        Navigator.pop(context);
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        DInfo.toastError('Failed Update');
      }
    }
  }

  @override
  void initState() {
    namaController.text = widget.cars['nama'];
    descriptionController.text = widget.cars['description'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Update Page'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DInput(
              controller: namaController,
              title: 'Merek',
              validator: (input) => input == '' ? "Tidak Boleh Kosong" : null,
            ),
            DView.spaceHeight(),
            DInput(
              controller: descriptionController,
              maxLine: 5,
              minLine: 1,
              title: 'Description',
              validator: (input) => input == '' ? "Tidak Boleh Kosong" : null,
            ),
            DView.spaceHeight(),
            ElevatedButton(
              onPressed: () => pickImage(),
              child: Text("Pick Image"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
              ),
            ),
            DView.spaceHeight(),
            newImageByte == null
                ? Image.network(
                    'http://192.168.1.27/task_crudmysql/image/${widget.cars['image']}',
                    height: 280,
                    fit: BoxFit.cover,
                  )
                : Image.memory(
                    newImageByte!,
                    height: 280,
                    fit: BoxFit.fitHeight,
                  ),
            DView.spaceHeight(),
            ElevatedButton(
              onPressed: () => update(),
              child: Text("Simpan"),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
