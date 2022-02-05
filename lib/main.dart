import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main(List<String> args) {
  runApp(const BadCharacterApp());
}

class BadCharacterApp extends StatefulWidget {
  const BadCharacterApp({Key? key}) : super(key: key);

  @override
  State<BadCharacterApp> createState() => _BadCharacterAppState();
}

class _BadCharacterAppState extends State<BadCharacterApp> {
  bool darkMode = false;

  toggleTheme() {
    setState(() {
      darkMode = !darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bad Characters',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: BadHome(toggleTheme: toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BadHome extends StatelessWidget {
  const BadHome({Key? key, required this.toggleTheme}) : super(key: key);
  final toggleTheme;

  Future<dynamic> geAllCharacters() async {
    var res =
        await get(Uri.parse("https://www.breakingbadapi.com/api/characters"));
    if (res.statusCode == 200) {
      List characters = json.decode(res.body);
      return characters;
    } else {
      return print('error getting characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    Future futureData = geAllCharacters();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bad Characters'),
      ),
      body: FutureBuilder<dynamic>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data.length ?? 0,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data[index]['name']),
                subtitle: Text(snapshot.data[index]['status']),
                trailing: CircleAvatar(
                  child: Text(
                    snapshot.data[index]['char_id'].toString(),
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(snapshot.data[index]['img']),
                ),
              );
            },
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text('Dark Mode'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleTheme,
        child: const Icon(Icons.brightness_6),
      ),
    );
  }
}
