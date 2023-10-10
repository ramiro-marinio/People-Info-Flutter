import 'dart:convert';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peopleinfo/maroon.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Map> getdata() async {
    var information =
        await http.get(Uri.parse("https://randomuser.me/api/?results=15"));
    return jsonDecode(information.body);
  }

  @override
  Widget build(BuildContext context) {
    Future<void> contactperm() async {
      const permission = Permission.contacts;
      if (await permission.status == PermissionStatus.denied) {
        await permission.request();
      }
    }

    contactperm();
    var req = getdata();
    return MaterialApp(
      theme: ThemeData(fontFamily: "Courier", primarySwatch: mcgpalette0),
      home: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text(
                  "People info",
                  style: TextStyle(fontFamily: "Roboto"),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        req = getdata();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 27, 118, 192)),
                    child: const Text(
                      "Reload",
                      style: TextStyle(fontFamily: "Roboto"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      "PEOPLE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: Color.fromARGB(150, 255, 0, 0),
                            offset: Offset(5.0, 5.0),
                          ),
                          Shadow(
                            color: Color.fromARGB(150, 0, 255, 255),
                            offset: Offset(-5.0, -5.0),
                          ),
                        ],
                        fontSize: 60,
                      ),
                    ),
                  ),
                  //Put the people here
                  FutureBuilder(
                      future: req,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          final results = snapshot.data?["results"];
                          List<Widget> people = [];
                          for (var user in results) {
                            people += [
                              _Person(
                                title: user["name"]["title"],
                                fullname: user["name"]["first"] +
                                    " " +
                                    user["name"]["last"],
                                image: user["picture"]["medium"],
                                telephone: user["cell"],
                                email: user["email"],
                                countrycode: user["nat"],
                                country: user["location"]["country"],
                              ),
                            ];
                          }
                          return Column(children: people);
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          throw Exception("negro puto");
                        }
                      })
                ],
              )
            ],
          )),
    );
  }
}

//PERSON CLASS
class _Person extends StatelessWidget {
  final String title;
  final String fullname;
  final String telephone;
  final String email;
  final String image;
  final String countrycode;
  final String country;
  const _Person(
      {required this.title,
      required this.fullname,
      required this.image,
      required this.telephone,
      required this.email,
      required this.countrycode,
      required this.country});
  @override
  Widget build(BuildContext context) {
    var phonewidth = MediaQuery.of(context).size.width;
    var cardwidth = phonewidth - phonewidth * 0.05;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(1, 1))
        ]),
        child: Card(
          color: const Color.fromARGB(255, 135, 0, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: SizedBox(
            width: cardwidth,
            height: 150,
            child: Stack(
              children: [
                Positioned(
                  top: cardwidth * 0.03,
                  left: cardwidth * 0.05,
                  child: Text(
                    "$title $fullname",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: cardwidth * 0.05,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(image),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: cardwidth * 0.25,
                  child: Text(
                    "Phone number:$telephone",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: cardwidth * 0.25,
                  child: Text(
                    "Email:$email",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Positioned(
                  left: cardwidth * 0.05,
                  top: 120,
                  child: Row(children: [
                    Text(
                      country,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    CountryFlag.fromCountryCode(
                      countrycode,
                      height: 20,
                      width: 30,
                    ),
                  ]),
                ),
                Positioned(
                    top: 100,
                    right: cardwidth * 0.05,
                    child: ElevatedButton(
                      child: const Text(
                        "Save Contact",
                        style: TextStyle(fontFamily: 'Roboto'),
                      ),
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text("Contact Saved!")),
                              ],
                            ),
                          ),
                        );
                        Future.delayed(const Duration(seconds: 1));
                        Contact contact = Contact(
                          name: Name(first: fullname),
                          emails: [Email(email)],
                        );
                        contact.insert();
                      },
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
