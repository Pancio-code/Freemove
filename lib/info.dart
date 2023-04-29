//@dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freemove/preferiti.dart';
import 'package:freemove/timeline.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: unused_import

class InfoPage extends StatefulWidget {
  const InfoPage({Key key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ListTile makeListTile(Icon categoria, String nome) => ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Container(
            padding: const EdgeInsets.only(right: 12.0),
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(width: 1.0, color: Colors.white24))),
            child: categoria,
          ),
          title: GestureDetector(
            child: Text(
              nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: nome));
              ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                content: new Text(
                  "Copied to Clipboard",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
              ));
            },
          ),
        );

    // ignore: non_constant_identifier_names
    Card makeCard(Icon categoria, String nome) => Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: makeListTile(categoria, nome),
          ),
        );

    // ignore: avoid_unnecessary_containers
    final makeBody = SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 30,
          ),
          makeCard(const Icon(Icons.place_outlined), "Roma"),
          makeCard(const Icon(Icons.person), "Andrea Panceri"),
          makeCard(const Icon(Icons.email_outlined), "Pancer.apps@gmail.com"),
          InkWell(
              child: makeCard(
                  const Icon(Icons.perm_device_information_outlined),
                  "FreeMove tutorial"),
              onTap: () =>
                  launch('https://www.youtube.com/watch?v=3VzMQyUOVP4')),
          const SizedBox(
            height: 30,
          ),
          makeCard(
              const Icon(
                Icons.warning_amber_outlined,
                color: Colors.deepOrangeAccent,
              ),
              "Segnalate solo quando la fermata è realmente affolata per far funzionare l'app correttamente.\nQuando vedete l'icona rossa come qui a sinistra la fermata è affolata"),
        ],
      ),
    );

    // ignore: avoid_unnecessary_containers, sized_box_for_whitespace
    final makeBottom = Container(
      height: 55.0,
      child: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
            IconButton(
              icon: const Icon(Icons.star),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PreferitiPage()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.list_alt_sharp),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TimeLinePage()));
              },
            )
          ],
        ),
      ),
    );

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Colors.black,
      centerTitle: true,
      title: const Text("FreeMove"),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: topAppBar,
      body: makeBody,
      bottomNavigationBar: makeBottom,
    );
  }
}
