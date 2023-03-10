import 'dart:convert';

import 'package:d_info/d_info.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:d_view/d_view.dart';
import 'package:task_crudmysql/create.dart';
import 'package:http/http.dart' as http;
import 'package:task_crudmysql/profile.dart';
import 'package:task_crudmysql/update.dart';

class HomePage extends StatefulWidget {
  final VoidCallback signOut;

  const HomePage(this.signOut);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List cars = [];

  read() async {
    String url = 'http://192.168.1.27/task_crudmysql/car/read.php';
    var response = await http.get(
      Uri.parse(url),
    );
    DMethod.printTitle('read', response.body);
    Map responseBody = jsonDecode(response.body);
    if (responseBody['success']) {
      cars = responseBody['data'];
      setState(() {});
    }
  }

  delete(Map car) async {
    bool? yes = await DInfo.dialogConfirmation(
      context,
      'Hapus',
      'Apakah Kamu yakin ingin menghapus?',
    );
    if (yes ?? false) {
      String url = 'http://192.168.1.27/task_crudmysql/car/delete.php';
      var response = await http.post(Uri.parse(url), body: {
        'id': car['id'],
        'image': car['image'],
      });
      Map responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        DInfo.toastSuccess('Success Delete');
        read();
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        DInfo.toastError('Failed Delete');
      }
    }
  }

  @override
  void initState() {
    read();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Home Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            signOut: widget.signOut,
                          )));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePage()),
          ).then((value) => read());
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      body: cars.isEmpty
          ? DView.empty()
          : ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                Map item = cars[index];
                return Card(
                  margin: EdgeInsets.fromLTRB(
                    16,
                    index == 0 ? 16 : 8,
                    16,
                    index == cars.length - 1 ? 80 : 8,
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.network(
                          'http://192.168.1.27/task_crudmysql/image/${item['image']}',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        DView.spaceWidth(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nama'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              DView.spaceHeight(4),
                              Text(
                                item['description'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                              ButtonBar(
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return UpdatePage(
                                              cars: item,
                                            );
                                          }),
                                        ).then((value) => read());
                                      },
                                      child: Text('Update'),
                                      style: ButtonStyle(backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) {
                                        return Colors.black;
                                      }))),
                                  ElevatedButton(
                                      onPressed: () => delete(item),
                                      child: Text('Delete'),
                                      style: ButtonStyle(backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) {
                                        return Colors.red;
                                      })))
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
