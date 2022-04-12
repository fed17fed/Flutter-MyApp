import 'dart:async';
import 'package:provider/provider.dart';

import '../services/firebase_options.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/post_detail.dart';
import '../models/post_model.dart';
import '../services/http_service.dart';

class TaskApp extends StatefulWidget {
  TaskApp({Key? key}) : super(key: key);

  @override
  _TaskAppState createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  late Future<List<Show>> shows;
  String searchString = "";
  final _suggestions = <String>[];
  final _saved = <String>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final CollectionReference _postss =
      FirebaseFirestore.instance.collection('posts');

  @override
  void initState() {
    super.initState();
    shows = fetchShows();  
    if (_saved.length > 0) {
      final favoriteSaved = true;
    }  
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
        appBar: AppBar(
          title: Text('Task app'),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite),
              // icon: Icon(
              //   favoriteSaved ? Icons.favorite : Icons.favorite_border,
              //   color: favoriteSaved ? Colors.red : null,
              //   semanticLabel: favoriteSaved ? 'Remove from saved' : 'Save',
              // ),
              onPressed: _pushSaved,
              tooltip: 'Saved Favorites',
            ),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Image.asset('Header-Banner.jpg'),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "World News",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.5,
                  fontSize: 40,
                ),
              ),
            ),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => Authentication(
                email: appState.email,
                loginState: appState.loginState,
                startLoginFlow: appState.startLoginFlow,
                verifyEmail: appState.verifyEmail,
                signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
                cancelRegistration: appState.cancelRegistration,
                registerAccount: appState.registerAccount,
                signOut: appState.signOut,
              ),
            ),
            const Divider(
              height: 20,
              thickness: 4,
              indent: 8,
              endIndent: 8,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 10),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (appState.loginState ==
                      ApplicationLoginState.loggedIn) ...[
                    const Header('News list'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchString = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Search',
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 340,
                      child: FutureBuilder(
                        builder: (context, AsyncSnapshot<List<Show>> snapshot) {
                          if (snapshot.hasData) {
                            return Center(
                              child: ListView.separated(
                                padding: const EdgeInsets.all(8),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final i = index ~/ 1;
                                  if (i >= _suggestions.length) {
                                    _suggestions
                                        .addAll({snapshot.data![i].title});
                                  }
                                  final alreadySaved =
                                      _saved.contains(_suggestions[i]);
                                  // print(alreadySaved);
                                  // print(_saved);
                                  return snapshot.data![index].title
                                          .toLowerCase()
                                          .contains(searchString)
                                      ? ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                '${snapshot.data?[index].urlToImage}'),
                                          ),
                                          title: Text(
                                              '${snapshot.data?[index].title}'),
                                          subtitle: Text(
                                              'Score: ${snapshot.data?[index].description}'),
                                          trailing: IconButton(
                                            icon: Icon(
                                              alreadySaved
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: alreadySaved
                                                  ? Colors.red
                                                  : null,
                                              semanticLabel: alreadySaved
                                                  ? 'Remove from saved'
                                                  : 'Save',
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (alreadySaved) {
                                                  _saved
                                                      .remove(_suggestions[i]);
                                                  final String? postId =
                                                      snapshot
                                                          .data?[index].title;
                                                  //print();
                                                  _postss.doc(postId).delete();
                                                } else {
                                                  _saved.add(_suggestions[i]);
                                                  final String? title = snapshot
                                                      .data?[index].title;
                                                  final String? description =
                                                      snapshot.data?[index]
                                                          .description;
                                                  //print();
                                                  _postss.doc(title).set({
                                                    "title": title,
                                                    "description": description
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PostDetail(
                                                show: snapshot.data![index],
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container();
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return snapshot.data![index].title
                                          .toLowerCase()
                                          .contains(searchString)
                                      ? Divider()
                                      : Container();
                                },
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Something went wrong :('));
                          }

                          return CircularProgressIndicator();
                        },
                        future: shows,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ));
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    final String? title = "_titleController.text";
    final String? description = '_descriptionController.text';
    //print(title);
    await _postss.add({"title": title, "description": description});
  }

  Future<void> _deletePost(String postId) async {
    await _postss.doc(postId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (elem) {
              //print(elem);
              return ListTile(
                title: Text(
                  elem,
                  style: _biggerFont,
                ),
              );
            },
          );

          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Favorites'),
            ),
            body: StreamBuilder(
              stream: _postss.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(documentSnapshot['title']),
                          subtitle:
                              Text(documentSnapshot['description'].toString()),
                          trailing: SizedBox(
                            width: 50,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _deletePost(documentSnapshot.id);
                                      _saved.remove(documentSnapshot['title']);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
      } else {
        _loginState = ApplicationLoginState.loggedOut;
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> verifyEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> registerAccount(
      String email,
      String displayName,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
