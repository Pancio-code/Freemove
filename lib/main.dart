//@dart=2.9
// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freemove/info.dart';
import 'package:freemove/preferiti.dart';
import 'package:freemove/theme.dart';
import 'package:freemove/timeline.dart';
// ignore: unused_import
import 'package:google_nav_bar/google_nav_bar.dart';
// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
// ignore: unused_import
import 'package:firebase_database/firebase_database.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

Icon actualIcon = const Icon(Icons.directions_subway_filled_outlined);
// ignore: non_constant_identifier_names
List Mezzi = [null, null, null];
var Signal = [].toList(growable: true);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [Locale('en'), Locale('it')],
      debugShowCheckedModeBanner: false,
      title: 'FreeMove',
      themeMode: ThemeMode.dark,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: unused_field
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final databaseReference = FirebaseDatabase.instance.reference();
  InterstitialAd _interstitialAd;

  // ignore: unused_element
  static BannerAd getBannerAd() {
    BannerAd bAd = BannerAd(
        size: AdSize.largeBanner,
        adUnitId: "ca-app-pub-4105105189383277/9884239709",
        listener: BannerAdListener(
            onAdClosed: (Ad ad) {
              print("Ad Closed");
            },
            onAdFailedToLoad: (Ad ad, LoadAdError error) {},
            onAdLoaded: (Ad ad) {
              print('Ad Loaded');
            },
            onAdOpened: (Ad ad) {
              print('Ad opened');
            }),
        request: const AdRequest());
    return bAd;
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd.dispose();
  }

  @override
  void initState() {
    getMezzi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    ListTile makeListTile(Mezzo Mezzo, int index) => ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Container(
            padding: const EdgeInsets.only(right: 12.0),
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(width: 1.0, color: Colors.white24))),
            child: actualIcon,
          ),
          title: Text(
            Mezzo.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.keyboard_arrow_right, size: 30.0),
          onTap: () {
            if (index == 0) {
              actualIcon = const Icon(Icons.directions_subway_filled_outlined);
            } else if (index == 1) {
              actualIcon = const Icon(Icons.tram_outlined);
            } else if (index == 2) {
              actualIcon = const Icon(Icons.directions_bus_filled_outlined);
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LineaPage(mezzo: Mezzo, tipo: index + 1)));
          },
        );

    // ignore: non_constant_identifier_names
    Card makeCard(Mezzo Mezzo, int index) => Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: makeListTile(Mezzo, index),
          ),
        );

    // ignore: avoid_unnecessary_containers
    final makeBody = Container(
      // decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, 1.0)),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: Mezzi.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 1) {
            actualIcon = const Icon(Icons.tram_outlined);
          } else if (index == 2) {
            actualIcon = const Icon(Icons.directions_bus_filled_outlined);
          }

          if (index != Mezzi.length) {
            return makeCard(Mezzi[index], index);
          } else {
            return Card(
              elevation: 8.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              // ignore: sized_box_for_whitespace
              child: Container(
                decoration: const BoxDecoration(color: Colors.black),
                child: AdWidget(
                  ad: getBannerAd()..load(),
                  key: UniqueKey(),
                ),
                height: 120,
              ),
            );
          }
        },
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
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const InfoPage()));
            },
            icon: Icon(Icons.info_outline)),
      ],
    );

    return FutureBuilder(
      // Initialize FlutterFire:
      future: getMezzi(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
            child: ErrorWidget(snapshot.error),
          ));
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
        // Otherwise, show something whilst waiting for initialization to complete
        return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            )));
      },
    );
  }

  Future<dynamic> getMezzi() async {
    // ignore: avoid_init_to_null
    Future _init = null;
    for (int i = 1; i < 5; i++) {
      _init = databaseReference
          .child(i.toString())
          .get()
          .then((DataSnapshot snapshot) {
        if (i < 4) {
          Map<dynamic, dynamic> values = snapshot.value;
          Mezzi[i - 1] = Mezzo(title: values['title'], linee: values['linee']);
        } else {
          Map<dynamic, dynamic> signals = snapshot.value;
          Signal = signals == null ? [] : signals['signals'];
        }
      });
    }
    return _init;
  }
}

class Mezzo {
  String title;
  List linee;

  Mezzo({this.title, this.linee});
}

class LineaPage extends StatefulWidget {
  final Mezzo mezzo;
  final int tipo;
  const LineaPage({Key key, this.mezzo, this.tipo}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<LineaPage> createState() => LineaPageState(mezzo, tipo);
}

class LineaPageState extends State<LineaPage> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final databaseReference = FirebaseDatabase.instance.reference();
  Mezzo m;
  int tipo;
  LineaPageState(this.m, this.tipo);
  TextEditingController searchController = TextEditingController();
  List _listNames = [];

  @override
  void initState() {
    super.initState();
    getLinee();
    searchController.addListener(() {
      getLinee();
    });
  }

  void getLinee() {
    _listNames = [];
    setState(() {
      for (int i = 0; i < m.linee.length; i++) {
        if (searchController.text.toLowerCase() == null) {
          _listNames.add([m.linee[i], i]);
        } else if ((m.linee[i]['title'])
            .toLowerCase()
            .contains(searchController.text.toLowerCase())) {
          _listNames.add([m.linee[i], i]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    ListTile makeListTile(Map<dynamic, dynamic> linea, int index) => ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: const EdgeInsets.only(right: 12.0),
          decoration: const BoxDecoration(
              border:
                  Border(right: BorderSide(width: 1.0, color: Colors.white24))),
          child: actualIcon,
        ),
        title: Text(
          linea['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.keyboard_arrow_right, size: 30.0),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FermatePage(
                      mezzo: Mezzo(
                          linee: m.linee[index]['fermate'],
                          title: m.linee[index]['title']),
                      index: index,
                      tipo: tipo.toString())));
        },
        onLongPress: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String nome = prefs.getString(linea['title']) ?? "";
          if (nome == "") {
            await prefs.setString(linea['title'], linea['title']);
            ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
              content: new Text(
                linea['title'] + " aggiunta alle tue linee preferite!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
              content: new Text(
                linea['title'] + " già fa parte delle tue linne preferite!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black,
            ));
          }
        });

    // ignore: non_constant_identifier_names
    Card makeCard(Map<dynamic, dynamic> linea, int index) => Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: makeListTile(linea, index),
          ),
        );

    // ignore: avoid_unnecessary_containers
    final makeBody = Container(
      // decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, 1.0)),
      child: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          height: _listNames.length > 7 ? _listNames.length * 80.0 + 815 : 700,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
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
                    style: TextStyle(color: Colors.white),
                    controller: searchController,
                    decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(
                          Icons.search_sharp,
                          color: Colors.white,
                        )),
                    cursorColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: _listNames.length > 0
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _listNames.length,
                        itemBuilder: (BuildContext context, int index) {
                          return makeCard(
                              _listNames[index][0], _listNames[index][1]);
                        },
                      )
                    : Text(
                        "Nessuna linea con questo nome",
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
      title: Text(m.title),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const InfoPage()));
            },
            icon: Icon(Icons.info_outline)),
      ],
    );

    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
            child: ErrorWidget(snapshot.error),
          ));
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
        // Otherwise, show something whilst waiting for initialization to complete
        return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(
          color: Colors.black,
        )));
      },
    );
  }
}

class FermatePage extends StatefulWidget {
  final Mezzo mezzo;
  final int index;
  final String tipo;
  const FermatePage({Key key, this.mezzo, this.index, this.tipo})
      : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<FermatePage> createState() => FermatePageState(mezzo, index, tipo);
}

class FermatePageState extends State<FermatePage> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final databaseReference = FirebaseDatabase.instance.reference();
  Mezzo m;
  // ignore: non_constant_identifier_names
  int index_linea;
  String tipo;
  FermatePageState(this.m, this.index_linea, this.tipo);
  InterstitialAd _interstitialAd;
  TextEditingController searchController = TextEditingController();
  List _listNames = [];

  @override
  void initState() {
    super.initState();
    _activateListeners();
    _createInterstitialAd();
    _CheckTimer();
    getFermate();
    searchController.addListener(() {
      getFermate();
    });
  }

  void getFermate() {
    _listNames = [];
    setState(() {
      for (int i = 0; i < m.linee.length; i++) {
        if (searchController.text.toLowerCase() == null) {
          _listNames.add([m.linee[i], i]);
        } else if ((m.linee[i]['nome'])
            .toLowerCase()
            .contains(searchController.text.toLowerCase())) {
          _listNames.add([m.linee[i], i]);
        }
      }
    });
  }

  // ignore: non_constant_identifier_names
  void _CheckTimer() async {
    var date = DateTime.now();
    for (int i = 0; i < m.linee.length; i++) {
      String key = "/" +
          tipo +
          '/linee/' +
          index_linea.toString() +
          '/fermate/' +
          i.toString();
      // ignore: non_constant_identifier_names
      DataSnapshot date_timer =
          await databaseReference.child(key + '/timer').get();
      if (date_timer.value == "") {
        continue;
      } else if (date.isAfter(DateTime.parse(date_timer.value))) {
        await databaseReference
            .update({key + '/timer': ""}).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Errore Controllo Timer: $error",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
          ));
          return;
        });
        await databaseReference
            .update({key + '/contatore': 0}).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Errore Controllo Timer: $error",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
          ));
          return;
        });
      }
    }
    setState(() {});
  }

  void _activateListeners() {
    databaseReference
        .child(tipo + "/linee/" + index_linea.toString())
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        m = Mezzo(
            linee: event.snapshot.value['fermate'],
            title: event.snapshot.value['title']);
        setState(() {});
      }
    });
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-4105105189383277/5944994699",
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _interstitialAd.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            _createInterstitialAd();
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    ListTile makeListTile(String fermata, Icon icon, int index) => ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Container(
            padding: const EdgeInsets.only(right: 20.0),
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(width: 1.0, color: Colors.white24))),
            child: icon,
          ),
          title: Text(
            fermata,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Builder(builder: (context) {
            if (index == 0) {
              return const Icon(Icons.arrow_downward_sharp);
            } else if (index == m.linee.length - 1) {
              return const Icon(Icons.arrow_upward_sharp);
            } else {
              return Column(
                children: const [
                  Icon(Icons.arrow_upward_sharp),
                  Icon(Icons.arrow_downward_sharp),
                ],
              );
            }
          }),
          onTap: () {
            if (index == 0 || index == m.linee.length - 1) {
              UpdateRecord();
              if (_interstitialAd != null) _showInterstitialAd();
            } else {
              showGeneralDialog(
                barrierLabel: "Barrier",
                barrierDismissible: true,
                barrierColor: Colors.black.withOpacity(0.5),
                transitionDuration: const Duration(milliseconds: 700),
                context: context,
                pageBuilder: (_, __, ___) {
                  return Material(
                    type: MaterialType.transparency,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 320,
                        child: SizedBox.expand(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  UpdateRecordFromFermata(index, "inizio");
                                  Navigator.pop(context);
                                  if (_interstitialAd != null)
                                    _showInterstitialAd();
                                },
                                child: Column(children: [
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  Text(
                                    m.linee[0]['nome'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Icon(
                                    Icons.arrow_upward_sharp,
                                    size: 70,
                                  ),
                                ]),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                fermata,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  UpdateRecordFromFermata(index, "fine");
                                  Navigator.pop(context);
                                  if (_interstitialAd != null)
                                    _showInterstitialAd();
                                },
                                child: Column(children: [
                                  const Icon(
                                    Icons.arrow_downward_sharp,
                                    size: 70,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    m.linee[m.linee.length - 1]['nome'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ]),
                              )
                            ],
                          ),
                        ),
                        margin: const EdgeInsets.only(
                            bottom: 50, left: 12, right: 12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  );
                },
                transitionBuilder: (_, anim, __, child) {
                  return SlideTransition(
                    position: Tween(
                            begin: const Offset(0, 1), end: const Offset(0, 0))
                        .animate(anim),
                    child: child,
                  );
                },
              );
            }
          },
          onLongPress: () {
            if (m.linee[index]['timer'] != "") {
              ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                content: new Text(
                  "Scadenza: " +
                      m.linee[index]['timer'].toString().substring(0, 16),
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                content: new Text(
                  "Nessuna segnalazione per la fermata " +
                      fermata +
                      m.linee[index]['timer'],
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
              ));
            }
          },
        );

    // ignore: non_constant_identifier_names
    Card makeCard(String fermata, Icon icon, int index) => Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: makeListTile(fermata, icon, index),
          ),
        );

    // ignore: avoid_unnecessary_containers
    final makeBody = Container(
      //decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, 1.0)),
      child: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          height: _listNames.length > 5
              ? _listNames.length * 90.0 + 200
              : _listNames.length * 80.0 + 200,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
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
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(
                          Icons.search_sharp,
                          color: Colors.white,
                        )),
                    cursorColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: _listNames.length > 0
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _listNames.length,
                        itemBuilder: (BuildContext context, int index) {
                          Icon icon = const Icon(Icons.warning_amber_outlined,
                              size: 30, color: Colors.green);
                          if (m.linee[index]['contatore'] == 1) {
                            icon = const Icon(Icons.warning_amber_outlined,
                                size: 30, color: Colors.deepOrange);
                          }
                          return makeCard(_listNames[index][0]['nome'], icon,
                              _listNames[index][1]);
                        },
                      )
                    : Text(
                        "Nessuna fermata con questo nome",
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
      title: Text(m.title),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const InfoPage()));
            },
            icon: Icon(Icons.info_outline)),
      ],
    );
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
            child: ErrorWidget(snapshot.error),
          ));
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
        // Otherwise, show something whilst waiting for initialization to complete
        return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(
          color: Colors.black,
        )));
      },
    );
  }

  // ignore: non_constant_identifier_names
  void UpdateRecord() async {
    var date = DateTime.now();
    var list = Signal.toList();
    list.insert(0, {'nome': m.title, 'durata': date.toString(), 'mezzo': tipo});
    Signal = list.toList();
    await databaseReference
        .child("4")
        .set({'signals': Signal}).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Errore nell' aggiunta della segnalazione: $error",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ));
      return;
    });
    int timer = 5;
    for (int i = 0; i < m.linee.length; i++) {
      // ignore: non_constant_identifier_names
      var date_timer = date.add(Duration(minutes: timer));
      String key = "/" +
          tipo +
          '/linee/' +
          index_linea.toString() +
          '/fermate/' +
          i.toString();
      await databaseReference
          .update({key + '/contatore': 1}).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Segnalazione non riuscita: $error",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ));
        return;
      });
      await databaseReference
          .update({key + '/timer': date_timer.toString()}).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Segnalazione non riuscita: $error",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ));
        return;
      });
      timer = timer + 5;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Segnalazione effettuata",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.black,
    ));
    setState(() {});
  }

  // ignore: non_constant_identifier_names
  void UpdateRecordFromFermata(int index, String verso) async {
    var date = DateTime.now();
    var list = Signal.toList();
    list.insert(0, {'nome': m.title, 'durata': date.toString(), 'mezzo': tipo});
    Signal = list.toList();
    await databaseReference
        .child("4")
        .set({'signals': Signal}).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Errore nell' aggiunta della segnalazione: $error",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ));
      return;
    });
    int timer = 5;
    if (verso == "inizio") {
      for (int i = index; i >= 0; i--) {
        // ignore: non_constant_identifier_names
        var date_timer = date.add(Duration(minutes: timer));
        String key = "/" +
            tipo +
            '/linee/' +
            index_linea.toString() +
            '/fermate/' +
            i.toString();
        await databaseReference
            .update({key + '/contatore': 1}).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Segnalazione non riuscita: $error",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
          ));
          return;
        });
        await databaseReference.update(
            {key + '/timer': date_timer.toString()}).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Segnalazione non riuscita: $error",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
          ));
          return;
        });
        timer += 5;
      }
    } else {
      for (int i = index; i < m.linee.length; i++) {
        // ignore: non_constant_identifier_names
        var date_timer = date.add(Duration(minutes: timer));
        String key = "/" +
            tipo +
            '/linee/' +
            index_linea.toString() +
            '/fermate/' +
            i.toString();
        await databaseReference
            .update({key + '/contatore': 1}).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Segnalazione non riuscita: $error",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
          ));
          return;
        });
        await databaseReference.update(
            {key + '/timer': date_timer.toString()}).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Segnalazione non riuscita: $error",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
          ));
          return;
        });
        timer += 5;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Segnalazione effettuata",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.black,
    ));
    setState(() {});
  }
}
