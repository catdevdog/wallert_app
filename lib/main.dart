import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkTheme = true;

  void _toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallert',
      theme: isDarkTheme
          ? ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
          accentColor: Colors.pinkAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      )
          : ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
          accentColor: Colors.pinkAccent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Wallert', toggleTheme: _toggleTheme, isDarkTheme: isDarkTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.toggleTheme, required this.isDarkTheme});

  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Row(
              children: [
                IconButton(
                  icon: Icon(widget.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
                  onPressed: widget.toggleTheme,
                )
              ],
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 10, // 카드의 수를 지정합니다.
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            elevation: 5,
            child: ListTile(
              leading: Icon(
                Icons.account_circle,
                size: 50,
                color: widget.isDarkTheme ? Colors.white : Colors.black,
              ),
              title: Text(
                'Card Title $index',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                'This is the subtitle for card number $index.',
                style: TextStyle(
                  color: widget.isDarkTheme ? Colors.white70 : Colors.black87,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward,
                color: widget.isDarkTheme ? Colors.white : Colors.black,
              ),
              onTap: () {
                // 카드 탭했을 때의 동작을 정의합니다.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Card $index tapped!')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
