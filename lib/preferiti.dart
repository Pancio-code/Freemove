//@dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:freemove/info.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:freemove/main.dart';
import 'package:freemove/timeline.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';

class PreferitiPage extends StatefulWidget {
  const PreferitiPage({Key key}) : super(key: key);

  @override
  State<PreferitiPage> createState() => _PreferitiPageState();
}

class _PreferitiPageState extends State<PreferitiPage> {
  // ignore: unused_field
  Future<int> _future;
  // ignore: unused_field
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final databaseReference = FirebaseDatabase.instance.reference();

  // ignore: non_constant_identifier_names
  List linee_searching = [];
  TextEditingController searchController = TextEditingController();
  // ignore: non_constant_identifier_names
  int num_of_prefe = 0;

  @override
  void initState() {
    _future = getTrattePreferite();
    searchController.addListener(() {
      getTrattePreferite();
    });
    super.initState();
  }

  Future<int> getTrattePreferite() async{
    linee_searching = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for(int i = 0; i < 3;i++) {
      // ignore: non_constant_identifier_names
      var type_mezzo = Mezzi[i].linee;
      for(int j = 0;j < type_mezzo.length;j++) {
        String name = prefs.getString(Mezzi[i].linee[j]['title']) ?? "";
        if(searchController.text == "" && name != "") {
          linee_searching.add(Linea(Mezzi[i].linee[j]['title'],Mezzi[i].linee[j]['fermate'],i + 1,j,1));
        }
        else if((Mezzi[i].linee[j]['title']).toLowerCase().contains(searchController.text.toLowerCase()) && name != "" && searchController.text != "") {
          linee_searching.add(Linea(Mezzi[i].linee[j]['title'],Mezzi[i].linee[j]['fermate'],i + 1,j,1));
        } 
        else if((Mezzi[i].linee[j]['title']).toLowerCase().contains(searchController.text.toLowerCase()) && searchController.text != ""){
          linee_searching.add(Linea(Mezzi[i].linee[j]['title'],Mezzi[i].linee[j]['fermate'],i + 1,j,0));
        } 
      }
    }
    num_of_prefe = linee_searching.length;
    setState(() {});
    return num_of_prefe;
  }


  @override
  Widget build(BuildContext context) { 
    
    // ignore: non_constant_identifier_names
    ListTile makeListTile(Linea linea) => ListTile(

      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 12.0),
        decoration: const BoxDecoration(
          border: Border(
              right: BorderSide(width: 1.0, color: Colors.white24))),
        child: IconButton(
          icon: const Icon(Icons.favorite),
          color: linea.preferita == 1 ? Colors.red : Colors.white,
          tooltip: 'Add to favorite',
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if(linea.preferita == 0){
              await prefs.setString(linea.title, linea.title);
            }else{
              await prefs.setString(linea.title, "");
            }
            setState(() {
              if(linea.preferita == 0){
                linea.preferita = 1;
              } else {
                linea.preferita = 0;
              }
              getTrattePreferite();
            });
          }
        ),
      ),
      title: Text(
        linea.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing:
        IconButton(
        icon:const Icon(Icons.keyboard_arrow_right, size: 30.0,),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FermatePage(mezzo: Mezzo(title: linea.title,linee: linea.fermate),index: linea.index ,tipo: linea.tipo.toString())));
        },
      ),
    );

    // ignore: non_constant_identifier_names
    Card makeCard(Linea linea) => Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: makeListTile(linea),
          ),
        );

    // ignore: avoid_unnecessary_containers
    final makeBody = Center(
      child: SingleChildScrollView(
        physics: const ScrollPhysics(),
        // ignore: sized_box_for_whitespace
        child: Container(
          height : num_of_prefe * 80.0 + 800,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30,),
              // ignore: avoid_unnecessary_containers
              Container(
                child: Theme(
                  data: ThemeData(
                      primarySwatch: MaterialColor(
                        0xFFFFFFFF,
                        const <int, Color>{
                          50: const Color(0xFFFFFFFF),
                          100: const Color(0xFFFFFFFF),
                          200: const Color(0xFFFFFFFF),
                          300: const Color(0xFFFFFFFF),
                          400: const Color(0xFFFFFFFF),
                          500: const Color(0xFFFFFFFF),
                          600: const Color(0xFFFFFFFF),
                          700: const Color(0xFFFFFFFF),
                          800: const Color(0xFFFFFFFF),
                          900: const Color(0xFFFFFFFF),
                        },
                      ),
                  ),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(
                      color: Colors.white
                    ),
                    decoration: InputDecoration(
                      labelText: 'Search',
                      labelStyle: TextStyle(
                        color: Colors.white
                      ),
                      prefixIcon: Icon(
                        Icons.search_sharp,
                        color: Colors.white,
                      )
                    ),
                    cursorColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              Expanded(
                child: num_of_prefe > 0 ? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: linee_searching.length,
                  itemBuilder: (BuildContext context, int index) {
                    return makeCard(linee_searching[index]);
                  },
                ) : const Text(
                  "Nessuna tratta preferita\nCerca e aggiungila",
                  textAlign: TextAlign.center,
                  style: TextStyle(  
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
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
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.list_alt_sharp),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TimeLinePage()
                  )
                );
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

    return FutureBuilder(
      // Initialize FlutterFire:
      future: _future,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: ErrorWidget(snapshot.error), 
            )
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: topAppBar,
            body: makeBody,
            bottomNavigationBar: makeBottom,
          );
        }

        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white,) 
          )
        );
      }
    );
  }
}

class Linea {
  String title;
  List fermate;
  int tipo;
  int index;
  int preferita;

  Linea(this.title, this.fermate,this.tipo,this.index,this.preferita);
}

