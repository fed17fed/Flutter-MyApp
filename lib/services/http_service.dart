import 'dart:async';
import 'dart:convert';
import '../models/post_model.dart';
import 'package:http/http.dart' as http;

Future<List<Show>> fetchShows() async {
  var postsURL =
      "https://newsapi.org/v2/top-headlines?country=us&apiKey=47f62e251f5e4626b16d49114c6bc1bf";

  final response = await http.get(Uri.parse(postsURL));

  if (response.statusCode == 200) {
    var topShowsJson = jsonDecode(response.body)['articles'] as List;    
    var allShows = topShowsJson.map((show) => Show.fromJson(show)).toList();
    //print(allShows);
    return allShows;
  } else {
    throw Exception('Failed to load shows');
  }
}
