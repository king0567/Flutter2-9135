import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainScreen(),
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white))),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List _screens = [
    const HomePage(),
    const DataPage(),
    const ContactPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (pageIndex) {
            setState(() {
              _currentIndex = pageIndex;
            });
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.data_usage), label: "Data"),
            NavigationDestination(
                icon: Icon(Icons.contact_mail), label: "Contact")
          ]),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              )),
            ),
          ),
          Expanded(
            child: Container(
                color: Theme.of(context).colorScheme.primary,
                child: Center(
                  child: Transform.rotate(
                    angle: 0.7,
                    child: Text(
                      "Hello!!",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }
}

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Future<List<Product>> _data;

  @override
  void initState() {
    super.initState();
    _data = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List<Product>>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {
                final data = snapshot.data!;
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: ListTile(
                            leading: Image.network(
                              data[index].thumbnail,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              data[index].name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            subtitle: Text(data[index].description),
                          ),
                        ),
                      );
                    });
              } else {
                return const Text('No data');
              }
            }));
  }

  Future<List<Product>> fetchData() async {
    final response =
        await http.get(Uri.parse('https://dummyjson.com/products'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body)['products'];
      return jsonData
          .map((data) => Product(
              id: data['id'],
              name: data['title'],
              description: data['description'],
              thumbnail: data['thumbnail']))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();

  final ContactDetails _data = ContactDetails();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formStateKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Contact Us!",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'name',
                      labelStyle: Theme.of(context).textTheme.labelLarge,
                      hintText: 'what do you want to be called',
                      icon: const Icon(Icons.person),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 0.0)),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.bodyMedium,
                  autofocus: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    _data.name = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'email',
                      labelStyle: Theme.of(context).textTheme.labelLarge,
                      hintText: 'where can we respond back',
                      icon: const Icon(Icons.mail),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 0.0)),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.bodyMedium,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    _data.email = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'message',
                    labelStyle: Theme.of(context).textTheme.labelLarge,
                    hintText: 'what do you want to tell us',
                    icon: const Icon(Icons.message),
                    alignLabelWithHint: true,
                  ),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.next,
                  maxLines: 5,
                  style: Theme.of(context).textTheme.bodyMedium,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    _data.message = value!;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      if (_formStateKey.currentState!.validate()) {
                        _formStateKey.currentState!.save();
                      }
                    },
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.send),
                      SizedBox(width: 8),
                      Text("Send")
                    ]))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactDetails {
  late String name;
  late String email;
  late String message;
}

class Product {
  final int id;
  final String name;
  final String description;
  final String thumbnail;

  Product(
      {required this.id,
      required this.name,
      required this.description,
      required this.thumbnail});
}
