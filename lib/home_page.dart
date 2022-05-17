// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final fnController = TextEditingController();
  final lnController = TextEditingController();
  late Database db;
  final data = [];

  @override
  void dispose() {
    fnController.dispose();
    lnController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    db = await openDatabase("mydb.db");
    await db.execute(
      "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, firstName TEXT, lastName TEXT)",
    );
    var records = await db.rawQuery("SELECT * FROM users");
    setState(() {
      data.addAll(records);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add User")),
      body: Column(
        children: <Widget>[
          TextField(
            controller: fnController,
            decoration: InputDecoration(labelText: "First Name"),
          ),
          TextField(
            controller: lnController,
            decoration: InputDecoration(labelText: "Last Name"),
          ),
          ElevatedButton(
            child: Text("Add"),
            onPressed: () {
              db.transaction((txn) async {
                await txn.rawInsert(
                  "INSERT INTO users (firstName, lastName) VALUES (?, ?)",
                  [fnController.text, lnController.text],
                );
              });
              fnController.clear();
              lnController.clear();
            },
          ),
          Expanded(
              child: ListView(
            children: [
              ...data.map((e) => ListTile(
                    title: Text("${e["firstName"]} ${e["lastName"]}"),
                  )),
            ],
          )),
        ],
      ),
    );
  }
}
