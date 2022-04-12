import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostDetail extends StatelessWidget {
  final Show show;

  PostDetail({required this.show});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${show.title}"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ListTile(
                        title: const Text("Title"),
                        subtitle: Text("${show.title}"),                        
                      ),
                      ListTile(
                        title: const Text("Image"),
                        subtitle: Image.network(
                          "${show.urlToImage}",
                          height: 200,
                        ),
                        //subtitle: Text("${articles.author}"),
                      ),
                      ListTile(
                        title: const Text("Page address"),
                        subtitle: Text("${show.url}"),
                      ),
                      ListTile(
                        title: const Text("Score"),
                        subtitle: Text("${show.description}"),
                      ),
                      ListTile(
                        title: const Text("User imageUrl"),
                        subtitle: Text("${show.urlToImage}"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
