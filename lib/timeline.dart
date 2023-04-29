//@dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:freemove/info.dart';
import 'package:freemove/main.dart';
import 'package:freemove/preferiti.dart';
// ignore: unused_import

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  // ignore: unused_field
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _CheckTime();
  }

  @override
  Widget build(BuildContext context) { 
      ListTile makeListTile(String nome,String durata,String mezzo) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text(
          durata + " " + "| MEZZO: " + mezzo + " | LINEA: " +  nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
    );

    // ignore: non_constant_identifier_names
    Card makeCard(String nome,String durata,String mezzo) => Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: makeListTile(nome,"("+ durata.substring(8,10) +")" + durata.substring(10,16),mezzo),
      ),
    );

    // ignore: avoid_unnecessary_containers
    final makeBody = Container(
      //decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, 1.0)),
      child: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          height : Signal.length > 5 ? Signal.length * 90.0 + 200  : Signal.length * 80.0  + 300,
          child: Column(
            children: <Widget>[
              SizedBox(height: 30,),
              Expanded(
                child: Signal.length > 0 ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: Signal.length,
                  itemBuilder: (BuildContext context, int index) {
                    String mezzo = "MetroFerro";
                    if(Signal[index]['mezzo'] == "2") {
                      mezzo = "Tram";
                    }
                    else if(Signal[index]['mezzo'] == "3") {
                      mezzo = "Bus";
                    }
                    return makeCard(Signal[index]['nome'],Signal[index]['durata'],mezzo);
                  },
                ) : Text(
                  "Nessuna segnalazione nelle ultime 24H",
                  textAlign: TextAlign.center,
                  style: TextStyle(  
                    fontSize: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // ignore: avoid_unnecessary_containers, sized_box_for_whitespace
    final makeBottom = Container(
      height: 55.0,
      child: BottomAppBar(
        color:  Colors.black,
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
                    builder: (context) => const PreferitiPage()
                  )
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.list_alt_sharp),
              onPressed: () {},
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
      actions: [
        IconButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InfoPage()
            )
          );
        }, icon: Icon(Icons.info_outline)),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: topAppBar,
      body: makeBody,
      bottomNavigationBar: makeBottom,
    );
  }

    // ignore: non_constant_identifier_names
  void _CheckTime() async {
    var date = DateTime.now();   
     var list = Signal.toList();
    list.removeWhere((element) => date.difference(DateTime.parse(element['durata'])).inHours >= 24);
    Signal = list.toList();
    await databaseReference.child("4").set({'signals' : Signal})
      .catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Errore nel controllo timer: $error",style: const TextStyle(color: Colors.white),),
          backgroundColor: Colors.black,
        ));
        return;
      }
    );
    setState(() {}); 
  }
}

