import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Database database;
  List<Map> list;
  String path;
  bool loaded = false;
  String img64;
  ByteData x;
  Uint8List bytes;
  void functionality() async {
    var databasesPath = await getDatabasesPath();
    path = databasesPath + '/demo.db';
    print(path);
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL, image TEXT)');
    });

    Future<File> _fileFromImageUrl() async {
      final response = await get(Uri.parse(
          'https://qph.fs.quoracdn.net/main-thumb-202758824-200-jpnbgsumiucqfihinqprbyzulbttmury.jpeg'));

      final documentDirectory = await getApplicationDocumentsDirectory();

      final file = File(join(documentDirectory.path, 'imagetest.jpeg'));

      file.writeAsBytesSync(response.bodyBytes);

      return file;
    }

    File f = await _fileFromImageUrl();

    final bytes = f.readAsBytesSync();

    img64 = base64Encode(bytes);
    print(img64.substring(0, 100));

    // await database.transaction((txn) async {
    //   int id1 = await txn.rawInsert(
    //       'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
    //   print('inserted1: $id1');
    //   int id2 = await txn.rawInsert(
    //       'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
    //       ['another name', 12345678, 3.1416]);
    //   print('inserted2: $id2');
    // });
    // list = await database.rawQuery('SELECT * FROM Test');
    // print(list);
    // await database
    //     .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
    // list = await database.rawQuery('SELECT * FROM Test');
    // print(list);
    // await deleteDatabase(path);
    // await database.close();
  }

  @override
  void initState() {
    super.initState();
    functionality();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //mainAxisSize: MainAxisSize.max,
          children: [
            TextButton(
              onPressed: () async {
                await database.transaction((txn) async {
                  // int id1 = await txn.rawInsert(
                  //     'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
                  // print('inserted1: $id1');
                  int id2 = await txn.rawInsert(
                      'INSERT INTO Test(name, value, num, image) VALUES(?, ?, ?, ?)',
                      ['another name', 12345678, 3.1416, img64]);
                  //print('inserted2: $id2');
                });
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () async {
                await database.rawDelete(
                    'DELETE FROM Test WHERE name = ?', ['another name']);
              },
              child: Text('Remove'),
            ),
            TextButton(
              onPressed: () async {
                bytes = base64.decode((await database
                    .rawQuery('SELECT image FROM Test'))[0]['image']);
                // print((await database.rawQuery('SELECT image FROM Test'))[0]
                //     ['image']);
                setState(() {
                  loaded = !loaded;
                });
              },
              child: Text('Show Image'),
            ),
            TextButton(
              onPressed: () async {
                list = await database.rawQuery('SELECT * FROM Test');
                print(list);
              },
              child: Text('Show'),
            ),
            TextButton(
              onPressed: () async {
                await deleteDatabase(path);
              },
              child: Text('Delete Database'),
            ),
            loaded ? Image.memory(bytes) : Text('hello'),
          ],
        ),
      ),
    );
  }
}
