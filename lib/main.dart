import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Anket"),
        ),
        body: const SurveyList(),
      ),
    );
  }
}

class SurveyList extends StatefulWidget {
  const SurveyList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SurverListState();
  }

}

class SurverListState extends State {

  CollectionReference surveys = FirebaseFirestore.instance.collection('dilanketi');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: surveys.snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return const LinearProgressIndicator();
          }else{
            return buildBody(context, snapshot.data!.docs);
          }
        }
    );
  }

  Widget buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map<Widget>((data) => buildListItem(context, data)).toList(),
    );
  }

  buildListItem(BuildContext context, DocumentSnapshot data) {
    final row = Anket.fromSnapshot(data);
    return Padding(
      key: ValueKey(row.isim),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(row.isim.toString()),
          trailing: Text(row.oy.toString()),
          onTap: () => FirebaseFirestore.instance.runTransaction((transaction) async {
            final freshSnapshot = await transaction.get(row.reference as DocumentReference);
            final fresh = Anket.fromSnapshot(freshSnapshot);

            transaction.update((row.reference  as DocumentReference), {"oy" : fresh.oy! + 1});
          }),
        ),
      ),
    );
  }
}

final sahteSnapshot = [
  {"isim" : "C#", "oy" : 3},
  {"isim" : "Java", "oy" : 4},
  {"isim" : "Dart", "oy" : 5},
  {"isim" : "C++", "oy" : 7},
  {"isim" : "Python", "oy" : 90},
  {"isim" : "Perl", "oy" : 2},
];

class Anket {
  String? isim;
  int? oy;
  DocumentReference? reference;

  Anket.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map["isim"]!=null), assert(map["oy"]!=null),
        isim = map["isim"], oy = map["oy"];

  Anket.fromSnapshot(DocumentSnapshot snapshot):
        this.fromMap((snapshot.data() as Map<String, dynamic>), reference: snapshot.reference);

}